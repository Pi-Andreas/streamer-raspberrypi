#!/usr/bin/env bash
# Build the streamer plugin for the Raspberry Pi (64-bit ARM Linux) open.mp
# server and pack raspberrypi/dist/streamer-linux-arm64.tar.gz, laid out to
# unpack into the server folder:
#
#   plugins/streamer.so              the plugin
#   qawno/include/streamer.inc       Pawn include
#
# The upstream CMake build needs Zeex's samp-plugin-sdk and cmake-modules,
# which are no longer on GitHub, so this compiles directly: the SA-MP plugin
# SDK copy in raspberrypi/sdk, Debian's Boost and Eigen headers, and the same
# definitions as src/CMakeLists.txt. Builds in a linux/arm64 Debian 12
# container (glibc 2.36, matching Raspberry Pi OS bookworm and the
# Pi-Andreas/omp-server-raspberrypi server).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Everything, packaging included, runs in the container; the outputs are then
# handed back to the calling user (the container runs as root, which on a
# Linux host would leave root-owned files the caller can't overwrite).
docker run --rm --platform linux/arm64 -v "$ROOT:/src" -w /src \
	-e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" debian:bookworm bash -euo pipefail -c '
	apt-get update -qq
	apt-get install -y -qq --no-install-recommends build-essential libboost-dev libeigen3-dev >/dev/null
	obj=build-raspberrypi
	stage=raspberrypi/dist/stage
	rm -rf "$obj" "$stage"
	mkdir -p "$obj" "$stage/plugins" "$stage/qawno/include"
	defs="-DLINUX -DHAVE_STDINT_H=1 -DHAVE_ALLOCA_H=1 -DSAMPGDK_AMALGAMATION -DSAMPGDK_CPP_WRAPPERS"
	incs="-Iraspberrypi/sdk -Iraspberrypi/sdk/amx -I/usr/include/eigen3 -Isrc"
	flags="-O2 -fPIC -fno-strict-aliasing -w"
	gcc -c $flags $defs $incs src/sampgdk.c -o "$obj/sampgdk.o"
	# At most 4 at a time: the Boost.Geometry-heavy files need ~1 GB each.
	export flags defs incs obj
	ls src/*.cpp src/manipulation/*.cpp src/natives/*.cpp src/utility/*.cpp raspberrypi/sdk/amxplugin.cpp |
		xargs -P 4 -I{} sh -c '"'"'g++ -c -std=c++17 $flags $defs $incs "{}" -o "$obj/$(echo "{}" | tr / _).o"'"'"'
	g++ -shared -o "$stage/plugins/streamer.so" "$obj"/*.o -lrt
	cp streamer.inc "$stage/qawno/include/"

	tar --owner=0 --group=0 -C "$stage" -czf raspberrypi/dist/streamer-linux-arm64.tar.gz plugins qawno
	rm -rf "$stage"
	(cd raspberrypi/dist && sha256sum streamer-linux-arm64.tar.gz > streamer-linux-arm64.tar.gz.sha256)
	chown -R "$HOST_UID:$HOST_GID" raspberrypi/dist "$obj"
'
echo "built: $ROOT/raspberrypi/dist/streamer-linux-arm64.tar.gz"
