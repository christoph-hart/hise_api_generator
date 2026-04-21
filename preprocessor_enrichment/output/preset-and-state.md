---
title: Preset & State
description: Exported plugin state handling — AppData location, asset baking, first-launch folders, preset overwrite policy, tempo persistence, undo coalescing.
---

Preprocessors in this category control how the exported plugin stores its state on disk and in the DAW project. They pick the AppData location (per-user or system-wide), decide whether external asset files are baked into the binary or resolved at runtime, gate the automatic creation of the UserPresets and Expansions folders on first launch, configure the preset overwrite and read-only factory policy, choose whether the host tempo is persisted with the DAW state, and set the undo coalescing interval. A few of these flags are written automatically by the export dialog from project settings; the rest are one-off product decisions that should be made before the first public release.

### `USE_RELATIVE_PATH_FOR_AUDIO_FILES`

Store non-streaming audio file references in presets as paths relative to an installed AudioFiles folder.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

When enabled, the exported plugin stores and resolves audio file references using the `{AUDIO_FILES}` wildcard against an AudioFiles subfolder inside the plugin's AppData directory, and the folder is created automatically if it does not exist yet. When disabled, user presets store the full absolute path from the machine that saved them, which breaks on any other computer.
> Only affects exported plugins. The HISE IDE always resolves audio files against the current project folder. Turn this off only if you deliberately manage the audio file location in HISEScript and don't want the AppData subfolder to be created.
