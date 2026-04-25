---
title: Preset & State
description: Exported plugin state handling — AppData location, asset baking, first-launch folders, preset overwrite policy, tempo persistence, undo coalescing.
---

Preprocessors in this category control how the exported plugin stores its state on disk and in the DAW project. They pick the AppData location (per-user or system-wide), decide whether external asset files are baked into the binary or resolved at runtime, gate the automatic creation of the UserPresets and Expansions folders on first launch, configure the preset overwrite and read-only factory policy, choose whether the host tempo is persisted with the DAW state, and set the undo coalescing interval. A few of these flags are written automatically by the export dialog from project settings; the rest are one-off product decisions that should be made before the first public release.

### `CONFIRM_PRESET_OVERWRITE`

Shows a confirmation popup before overwriting an existing user preset file.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

When enabled, saving a user preset on top of an existing file name opens a yes/no dialog asking whether to replace the file or cancel the save. When disabled, the existing file is deleted and replaced silently, which is useful when a scripted save flow already handles overwrite logic through its own UI. Only affects the built-in save path in the HISE IDE and the stock preset browser, not scripted saves that write preset files directly.
> Disable this if your plugin ships a custom preset browser that handles overwrite confirmation itself, otherwise the user sees two confirmation popups in a row.

**See also:** $UI.FloatingTiles.PresetBrowser$ -- preset browser save action is the main caller of the confirmation dialog, $PP.HISE_OVERWRITE_OLD_USER_PRESETS$ -- related flag that governs silent overwrite behaviour for shipped user presets in the exported plugin

### `DONT_CREATE_USER_PRESET_FOLDER`

Skips the automatic creation of the UserPresets folder on first launch of the exported plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

On first launch, an exported plugin normally extracts the embedded user preset bank into a UserPresets folder inside its AppData directory. Enabling this flag suppresses that extraction step entirely, so the folder is never created and no presets are written to disk. This is only useful for non-audio projects (utilities, licensing helpers, installers) that happen to be built with HISE but do not need the preset system at all.
> Only takes effect in exported plugins. Leaving it off is the right choice for every regular instrument or effect build.

**See also:** $PP.DONT_CREATE_EXPANSIONS_FOLDER$ -- sibling folder-suppression flag that skips the automatic Expansions folder for non-audio utility builds

### `DONT_EMBED_FILES_IN_FRONTEND`

Exports the plugin without baking the project's image, audio and sample map assets into the binary.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

By default the compile exporter embeds every external file (images, audio files, sample maps, MIDI files, scripts) into the compiled plugin so the binary is self-contained. Enabling this flag skips the embedding step, which produces a much smaller binary and dramatically faster load times, but the plugin will then look for every asset inside its project subfolder at runtime. On iOS builds the flag is forced on automatically because the platform ships external resources alongside the app bundle.
> Not recommended for desktop production builds because the plugin will fail to load any asset that is missing from the end user's file system.

**See also:** $PP.USE_RELATIVE_PATH_FOR_AUDIO_FILES$ -- companion flag that controls how non-embedded audio files are located at runtime

### `HISE_INCLUDE_TEMPO_IN_PLUGIN_STATE`

Stores and restores the current host tempo as part of the plugin's DAW project state.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | yes | no |

When enabled, the plugin writes the last known host BPM into the state chunk that the DAW saves with the project, and reads it back when the project is reopened. This is useful for standalone testing and for plugins that override the tempo through the scripting API, because the custom value survives a save/reload cycle. The side effect is a short window at project load where the stored tempo briefly takes effect before the host updates the value on the next audio block, which can cause subtle glitches on patches that are tightly locked to tempo-synced LFOs or delays.
> Disable this if your plugin always follows the host tempo and you prefer clean startups over persisting a custom BPM.

**See also:** $API.TransportHandler$ -- host BPM reported through the transport handler is the value that gets persisted, $API.Engine.getHostBpm$ -- Engine.getHostBpm reflects the restored tempo after a project reload

### `HISE_OVERWRITE_OLD_USER_PRESETS`

Silently replaces shipped user presets on disk when the plugin version is newer than the one that wrote them.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | yes |

Controls how the exported plugin reacts when its bundled user preset bank on disk was written by an older build. When disabled, an existing UserPresets folder is left untouched and the embedded bank is only extracted on first launch. When enabled, the plugin compares the version stamp in an info.json file and, if the current plugin version is newer, rewrites every factory-shipped preset (including any that the end user has modified), while leaving presets that the user created themselves alone unless a name collision occurs.
> The HISE export dialog writes this flag automatically from the 'Overwrite Old User Presets' project setting, so you normally don't need to set it manually in the ExtraDefinitions field.

**See also:** $PP.READ_ONLY_FACTORY_PRESETS$ -- related flag that stops the user from modifying shipped presets in the first place, $PP.CONFIRM_PRESET_OVERWRITE$ -- related flag that governs the overwrite confirmation on manual saves in the HISE IDE

### `HISE_UNDO_INTERVAL`

Milliseconds between undo coalescing ticks for the global undo manager.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `500` | no | no |

Sets the period of the timer that flushes pending undo transactions on the main controller. Rapid parameter changes inside one tick are merged into a single undoable step, so a lower value gives finer-grained undo history at the cost of longer undo stacks, while a higher value coalesces more aggressively and keeps the history shorter. The default of 500 ms matches a comfortable knob-drag granularity for most users; values below about 100 ms start creating one undo step per UI message, which quickly fills the history with noise.
> Sensible range is roughly 100 to 2000 milliseconds. Only changing this is worthwhile if you have specific undo granularity requirements in a large utility project.

### `HISE_USE_SYSTEM_APP_DATA_FOLDER`

Stores user presets, audio files and plugin state under the shared system AppData folder rather than the per-user one.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | yes |

Switches the AppData directory that the exported plugin uses from the current user's application data folder to the system-wide shared folder. This means every user on the machine reads and writes the same preset bank and resource folder, which is useful for multi-user studio setups and for installers that place content in a shared location. Writing to the shared folder usually requires elevated privileges, so the installer and the plugin need to be configured accordingly. The HISE IDE always checks the project setting at runtime regardless of this compile-time value.
> The HISE export dialog writes this flag automatically from the 'Use Global AppData Folder' project setting, so you normally don't need to set it manually in the ExtraDefinitions field.

**See also:** $PP.USE_RELATIVE_PATH_FOR_AUDIO_FILES$ -- audio files are resolved against the same AppData location selected by this flag

### `READ_ONLY_FACTORY_PRESETS`

Marks every shipped user preset as read-only so users cannot overwrite factory content.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | yes |

When enabled, the exported plugin tracks the list of file paths that were extracted from the embedded preset bank and expansions, and refuses to overwrite any of them from the preset save path. Users can still save new presets alongside the factory bank, they just cannot replace a shipped preset file. The Engine.isUserPresetReadOnly scripting method reports this status so a custom preset browser can hide or grey out the save button on factory entries.
> The HISE export dialog writes this flag automatically from the 'Read Only Factory Presets' project setting, so you normally don't need to set it manually in the ExtraDefinitions field.

**See also:** $API.Engine.isUserPresetReadOnly$ -- Engine.isUserPresetReadOnly reports the read-only status that this flag enables, $API.UserPresetHandler$ -- scripted preset handler queries the factory path list that this flag populates, $PP.HISE_OVERWRITE_OLD_USER_PRESETS$ -- related flag that governs automatic overwriting of shipped presets across plugin versions

### `USE_RELATIVE_PATH_FOR_AUDIO_FILES`

Store non-streaming audio file references in presets as paths relative to an installed AudioFiles folder.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

When enabled, the exported plugin stores and resolves audio file references using the `{AUDIO_FILES}` wildcard against an AudioFiles subfolder inside the plugin's AppData directory, and the folder is created automatically if it does not exist yet. When disabled, user presets store the full absolute path from the machine that saved them, which breaks on any other computer.
> Only affects exported plugins. The HISE IDE always resolves audio files against the current project folder. Turn this off only if you deliberately manage the audio file location in HISEScript and don't want the AppData subfolder to be created.

**See also:** $PP.DONT_EMBED_FILES_IN_FRONTEND$ -- companion flag that skips embedding of external asset files entirely, $PP.HISE_USE_SYSTEM_APP_DATA_FOLDER$ -- selects whether the AppData root is the per-user or the system-wide folder
