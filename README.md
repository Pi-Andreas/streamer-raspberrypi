# streamer for Raspberry Pi

This fork builds the streamer plugin **v2.9.6** for the **64-bit ARM open.mp
server on a Raspberry Pi**
([Pi-Andreas/omp-server-raspberrypi](https://github.com/Pi-Andreas/omp-server-raspberrypi)).
Every change is in the
[compare view](https://github.com/samp-incognito/samp-streamer-plugin/compare/v2.9.6...Pi-Andreas:samp-streamer-plugin-raspberrypi:raspberrypi).

### Install on the Pi

Download `streamer-linux-arm64.tar.gz` from
[releases](https://github.com/Pi-Andreas/samp-streamer-plugin-raspberrypi/releases/latest)
and unpack it in the server folder (e.g. `~/omp-server`):

```bash
tar -xzf streamer-linux-arm64.tar.gz
```

That adds `plugins/streamer.so` and `qawno/include/streamer.inc`. Then add
`"streamer"` to `pawn.legacy_plugins` in `config.json`.

### What changed for ARM

- **sampgdk hooks:** streamer reaches the server through sampgdk, which hooks
  `amx_Register`, `amx_FindPublic`, `amx_Exec` and `amx_Allot` by patching
  their machine code, upstream for x86 only. `src/sampgdk.c` adds an AArch64
  hook: the first four instructions become `ldr x17, #8; br x17; .quad hook`,
  and the originals move to a trampoline with PC-relative instructions
  rewritten. Freeing a hook restores the original code.
- **64-bit native tables:** a 64-bit open.mp server stores native pointers
  full width over each native table entry. sampgdk's `funcidx` hook and
  streamer's native check (`src/utility/amx.cpp`) now write full pointers and
  read native names from the name table.
- **Include version:** `src/main.h` reports `0x296`, matching `streamer.inc`
  (as upstream `master` does).

Tested on a Raspberry Pi 4 with the open.mp arm64 server: dynamic objects,
areas, checkpoints, map icons, 3D labels and actors are created, `funcidx`
works, callbacks reach the plugin and the server shuts down cleanly.

### Build

`raspberrypi/build.sh` builds in a linux/arm64 Debian 12 container with Docker
and writes `raspberrypi/dist/streamer-linux-arm64.tar.gz`. The upstream CMake
build needs Zeex's `samp-plugin-sdk` and `cmake-modules`, which are no longer
on GitHub, so the script compiles directly against a copy of the SA-MP plugin
SDK in `raspberrypi/sdk` (with `SUPPORTS_PROCESS_TICK` from later SDK
releases) and Debian's Boost and Eigen headers. The `Raspberry Pi build`
workflow runs it on GitHub's arm64 runner and publishes a release for every
`v*-rpi*` tag; the upstream Windows workflow is removed on this branch.

---

# SA-MP Streamer Plugin
[![GitHub Release](https://img.shields.io/github/release/samp-incognito/samp-streamer-plugin.svg)](https://github.com/samp-incognito/samp-streamer-plugin/releases/latest) [![Build Status](https://github.com/samp-incognito/samp-streamer-plugin/actions/workflows/build.yml/badge.svg)](https://github.com/samp-incognito/samp-streamer-plugin/actions/workflows/build.yml)

This plugin streams objects, pickups, checkpoints, race checkpoints, map icons, 3D text labels, and actors at user-defined server ticks. Basic area detection is also included. Because it is written entirely in C++, much of the overhead from PAWN is avoided. This streamer, as a result, is quite a bit faster than any other implementation currently available in PAWN.

## Documentation

Documentation can  be found on the [wiki](https://github.com/samp-incognito/samp-streamer-plugin/wiki).

## Download

The latest binaries for Windows and Linux can be found on the [releases page](https://github.com/samp-incognito/samp-streamer-plugin/releases).
