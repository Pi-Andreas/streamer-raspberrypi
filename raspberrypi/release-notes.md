streamer **v2.9.6** built for the **Raspberry Pi open.mp server** — 64-bit ARM Linux, Raspberry Pi OS bookworm or newer. Use it with [Pi-Andreas/omp-server-raspberrypi](https://github.com/Pi-Andreas/omp-server-raspberrypi).

### Install

In the server folder (e.g. `~/omp-server`):

```bash
tar -xzf streamer-linux-arm64.tar.gz
```

That adds `plugins/streamer.so` and `qawno/include/streamer.inc`. Then add `"streamer"` to `pawn.legacy_plugins` in `config.json`.

### What changed for ARM

streamer reaches the server through sampgdk, which hooks four AMX functions by patching their machine code. Upstream only does that for x86. This build adds an AArch64 hook (absolute-jump patch plus a relocating trampoline) and makes the native-table writes in sampgdk and streamer store full 64-bit pointers, which a 64-bit open.mp server requires.

Tested on a Raspberry Pi 4 with the open.mp arm64 server: dynamic objects, areas, checkpoints, map icons, 3D labels and actors are created, `funcidx` works, callbacks reach the plugin and the server shuts down cleanly. Streaming to real players is the part to watch; please report issues on the repo.

SHA-256 `streamer-linux-arm64.tar.gz`: `{{SHA256}}`
