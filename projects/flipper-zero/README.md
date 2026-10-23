# Flipper Zero

> Custom Flipper Zero apps, asset packs, and scripts — built with Claude's help and running on [Momentum firmware](https://github.com/Next-Flip/Momentum-Firmware).

**Status:** 🚧 In progress · **Started:** 2026-10-22 · **Area:** Hardware

## Goal
Learn the Flipper Zero SDK by building real, working add-ons — apps, asset packs, and Bad USB scripts — and use each one as a small test of how well Claude can plan and write firmware-level code.

## How it works
The code lives in its own repo, [`lukepolich/flipper-custom`](https://github.com/lukepolich/flipper-custom), so it stays close to the `ufbt` build tooling and a Momentum firmware checkout. This folder is the catalog: every individual Flipper project gets a row below with a link into that repo.

Apps are built with `ufbt` (the Flipper micro-build tool) against the Momentum SDK. Asset packs are 128×64 1-bit PNG frames packed with a helper script. Bad USB scripts are DuckyScript text files the Flipper replays as a USB/Bluetooth keyboard.

## Individual projects

| Project | Type | What it is | Status |
| --- | --- | --- | --- |
| [hello_flipper](https://github.com/lukepolich/flipper-custom/tree/main/apps/hello_flipper) | App (.fap) | Starter app: a simple counter in the Tools category | 🚧 In progress |
| [MyPack](https://github.com/lukepolich/flipper-custom/tree/main/asset_packs/MyPack) | Asset pack | Custom "Hello" animation (4 frames, 128×64) for the Momentum UI | 🚧 In progress |
| [LJP-OS](LJP-OS/) | Firmware | My own Flipper OS: a fork of the official firmware (1.5.1) with LJP-OS branding, kept in this repo as a patch | 🚧 In progress |
| [BadKB scripts](https://github.com/lukepolich/flipper-custom/tree/main/badusb) | Bad USB | DuckyScript files: open a site, lock the PC, set up a workspace, type boilerplate, show network info | ✅ Working |

As new Flipper projects are built, add a row here and link it to its folder in `flipper-custom` (or, for LJP-OS, the folder here).

## AI's role
Claude Code did the planning and wrote most of the C, the asset-packing script, and the DuckyScript — including the repo layout and build docs in `flipper-custom`. Firmware work is unforgiving (SDK APIs, memory, exact build flags), so it's a good stress test of how well Claude holds up on low-level code.

## Running it
See the [`flipper-custom` README](https://github.com/lukepolich/flipper-custom#readme) for full setup. Short version:

```bash
# one-time setup
python -m pip install --user ufbt pillow heatshrink2
python -m ufbt update --index-url=https://up.momentum-fw.dev/firmware/directory.json --channel=release

# build an app
cd apps/hello_flipper
python -m ufbt            # output: dist/hello_flipper.fap

# build asset packs
python tools/pack_assets.py
```

## What I learned
_(fill in as projects progress — what worked, what didn't, SDK gotchas, and what I'd do differently.)_
