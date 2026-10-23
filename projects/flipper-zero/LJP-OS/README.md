# LJP-OS

> My own Flipper Zero firmware: a fork of the [official firmware](https://github.com/flipperdevices/flipperzero-firmware) with LJP-OS branding and features layered on top.

**Status:** 🚧 In progress · **Started:** 2026-10-22 · **Area:** Hardware

## Goal
Build and flash a complete, custom-branded Flipper OS (not just apps on top of someone else's firmware), and grow it over time with my own built-in apps, menus, and UI changes.

## How it works
The official firmware is ~280 MB with submodules, so this folder doesn't store it. Instead:

| Path | What it is |
| --- | --- |
| `ljp-os.ps1` | Helper script: setup, build, flash, save, reset |
| `patches/ljp-os.patch` | **The LJP-OS source of truth.** Every change made to the official firmware |
| `firmware/` | *(gitignored)* Official firmware pinned at release **1.5.1**, with the patch applied |

Workflow: edit code in `firmware/`, build and test it, then run `save` to capture the edits into the patch. Commit the patch. A fresh clone of this repo can rebuild the exact same OS with `setup` and `build`.

Upgrading upstream: change `$UpstreamTag` in `ljp-os.ps1`, delete `firmware/`, and run `setup` again. If the patch no longer applies cleanly, fix the conflicts and run `save`.

### What LJP-OS changes so far
- Firmware origin is set to `LJP_OS` (shown by `info` over CLI/qFlipper), and the build suffix to `ljp-os`. The origin has to be a valid C identifier, because the build turns it into a `FW_ORIGIN_<name>` macro, so `LJP-OS` with a hyphen fails to compile
- Settings → About opens on an LJP-OS screen, and the version page is titled "LJP-OS Version"
- **Dark mode, on by default.** The whole UI is inverted, so the orange backlight shows through as glowing text and icons on a black screen. It covers menus, apps, the dolphin, and direct-draw games, and qFlipper's screen mirror shows it too. Toggle it in Settings → System → Dark Mode. The setting is saved to `/int/.gui.settings` and survives reboots.

- **Quick Settings panel.** Press Up on the home screen. The old lock menu is now a scrolling panel: Lock, Dark Mode, Brightness, Volume, Bluetooth, Mute, and Dummy Mode. Up/Down moves, OK toggles, Left/Right adjusts brightness and volume in 5% steps (volume plays a preview beep). Toggles stay in the panel, and brightness/volume are saved once when you leave.
- **Better status bar.** Battery percentage next to the battery icon, plus the clock on by default for fresh installs. If you're upgrading from another firmware, turn the clock on once in Settings → Desktop.
- **Boot splash.** An LJP-OS logo with the base firmware version and a loading bar, shown for about 1.3 s while services start. It follows dark mode.
- **Built-in apps.** `build` copies every app in your [flipper-custom](https://github.com/lukepolich/flipper-custom) `apps/` folder into the firmware build and bundles it into the update package, so it installs with the firmware (e.g. Apps → Tools → Hello Flipper). Use `-AppsSource <folder>` to point somewhere else; if the folder doesn't exist, the build skips this step.

### How dark mode works
The Flipper's LCD is 1-bit monochrome, so "dark mode" means inverting pixels. The inversion happens in `canvas_commit()` (`applications/services/gui/canvas.c`), the one point every frame passes through. The frame is inverted, sent to the LCD and to framebuffer callbacks (screen streaming), and then flipped back, so apps that keep drawing into the same buffer never see inverted data. The setting lives in the GUI service (`gui_set_dark_mode()` in the private `gui_i.h`), so the public SDK and app compatibility are unchanged.

### Where the other features live
| Feature | Files in `firmware/` |
| --- | --- |
| Quick Settings | `applications/services/desktop/views/desktop_view_lock_menu.c` (UI), `scenes/desktop_scene_lock_menu.c` (applies settings) |
| Battery % | `applications/services/power/power_service/power.c` |
| Clock default | `applications/services/desktop/desktop_settings.c` |
| Boot splash | `gui_draw_boot_splash()` in `applications/services/gui/gui.c` |
| App bundling | `Sync-Apps` in `ljp-os.ps1`. Apps are copied to `applications_user/` and excluded from the patch |

## AI's role
Claude Code planned the fork layout (pinned upstream + patch file, so the showcase repo stays small), wrote the helper script, and made the firmware changes. Upstream's CONTRIBUTING only restricts AI-generated *PRs sent back to them*; a personal fork is fine. GPL-3.0 applies, so LJP-OS stays open source.

## Running it
Requires Windows, git, and a path without spaces (C:\dev\... works; OneDrive does not). The first build downloads the ARM toolchain automatically.

```powershell
cd projects\flipper-zero\LJP-OS
.\ljp-os.ps1 setup     # clone official 1.5.1 into firmware\ and apply LJP-OS patch
.\ljp-os.ps1 build     # -> firmware\dist\f7-C\flipper-z-f7-update-ljp-os.tgz (release build)
.\ljp-os.ps1 flash     # build + install over USB (close qFlipper first)
.\ljp-os.ps1 save      # after editing firmware\, store changes in patches\ljp-os.patch
```

To install without the CLI, open qFlipper, choose **Install from file**, and pick the `.tgz` from `firmware\dist\f7-C\`. To go back to stock, use qFlipper's normal **Update** (official release).

## What I learned
_(fill in as LJP-OS grows)_
