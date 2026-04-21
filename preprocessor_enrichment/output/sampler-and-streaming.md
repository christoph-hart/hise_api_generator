---
title: Sampler & Streaming
description: Streaming sampler backend and sample-installation UX — monolith access, preload threshold, release start, and SamplesNotInstalled overlay buttons.
---

Preprocessors in this category configure the streaming sampler backend and the sample-installation user experience in exported plugins. They pick between memory-mapped and file-handle-based monolith access, set the preload size above which a sample is loaded entirely into RAM, enable the release start feature with its editor and scripting API, control the install and locate buttons on the SamplesNotInstalled overlay, choose the folder versus file picker for the Relocate Samples action, and expose the Full Dynamics HLAC encoding option to end users. Most of these trade disk access patterns against memory footprint and against the sample archive size. The export dialog writes a couple of them from project settings, so the manual overrides mostly cover non-standard installer flows.

### `HISE_BROWSE_FOLDER_WHEN_RELOCATING_SAMPLES`

Controls whether relocating samples opens a folder picker or a file picker for a .ch1 file.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Changes the behaviour of the 'Relocate Samples' button in the standalone settings window of an exported plugin. When enabled, clicking it opens a folder browser so the user can point at the directory that contains the extracted sample archive. When disabled, it opens a file browser filtered to .ch1 files and uses the parent folder of the chosen file as the new sample location, which is useful if the installer produces a nested folder layout and you want the user to click on a known landmark file instead of navigating to the correct subfolder.
> Only affects the standalone settings dialog in the exported plugin. Has no effect inside the HISE IDE.

**See also:** $PP.HISE_SAMPLE_DIALOG_SHOW_LOCATE_BUTTON$ -- the locate button driven by that flag picks either a folder or file picker depending on this one

### `HISE_ENABLE_CROSSFADE_MODULATION_THRESHOLD`

Skips per-sample crossfade modulation when the control-rate signal is effectively constant over a block.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Affects how the sampler renders its group crossfade modulation chain. When enabled, the first and last control-rate values of each block are compared and if they differ by less than -80 dB the engine writes a single ramp value for the whole block instead of expanding the full modulation signal. This is a measurable CPU saving for patches with many voices in crossfaded groups where the modulation value is usually static. Disabling it always uses the full modulation signal and removes any chance of audible stepping when a crossfade slider is automated very slowly.
> Disable only if you hear subtle artifacts when crossfading between sampler groups and need the full per-sample resolution.

**See also:** $MODULES.StreamingSampler$ -- crossfade modulation chain of the sampler uses this control-rate shortcut, $API.Sampler$ -- scripted crossfade modulation relies on the same threshold behaviour

### `HISE_LOAD_ENTIRE_SAMPLE_THRESHHOLD`

Preload size in samples above which the streaming engine loads the entire sample into memory.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `2147483647` | no | no |

When a sample's preload buffer would exceed this threshold, the streaming engine skips disk streaming for that sample and loads it into memory in full. The default is INT_MAX which effectively disables the shortcut so every sample is streamed normally. Lower values (for example 28000) are useful as a workaround for rare edge cases where short samples produce clicks during streamed playback. The value is interpreted as a sample frame count, so memory cost scales with bit depth and channel count.
> Setting this too low forces a lot of short samples to stay fully in RAM and can noticeably inflate memory usage on large sample sets.

**See also:** $MODULES.StreamingSampler$ -- threshold above which the streaming engine falls back to a full in-memory load, $PP.USE_FALLBACK_READERS_FOR_MONOLITH$ -- companion streaming-backend knob that forces per-instance file handles regardless of size

### `HISE_SAMPLER_ALLOW_RELEASE_START`

Enables the release start feature on the sampler, including scripting APIs and the release start editor.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

When enabled, every sample can define a release start marker that the voice jumps to when the note is released, with configurable fade time, fade curve, zero crossing alignment, gain matching and peak smoothing. The full configuration is exposed in the sample editor and through Sampler.setReleaseStartOptions, Sampler.getReleaseStartOptions and Sampler.setAllowReleaseStart. Disabling it removes the feature entirely, which saves a small amount of per-voice state and removes the release start properties from the sample map format.
> Must be set consistently for both the HISE build and the exported plugin. Calling the release start scripting APIs with this disabled raises a script error.

**See also:** $MODULES.StreamingSampler$ -- release start marker and its sample editor UI are gated on this flag, $API.Sampler$ -- setReleaseStartOptions, getReleaseStartOptions and setAllowReleaseStart are only available when this flag is on

### `HISE_SAMPLE_DIALOG_SHOW_INSTALL_BUTTON`

Shows the 'Install Samples' button on the SamplesNotInstalled overlay in an exported plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Controls the install button in the overlay that appears when the exported plugin cannot find its sample archive. When enabled, the user can pick a downloaded .hr1 archive and the plugin extracts it into the sample folder using the built-in HLAC archiver. Disable this if you ship samples through a custom installer or a separate application and do not want the plugin to offer the HR1 extraction workflow. The default message shown on the overlay also changes depending on which of the install and locate buttons are enabled.
> If both this and the locate button are disabled, the SamplesNotInstalled overlay is suppressed completely.

**See also:** $API.ErrorHandler$ -- controls the install button on the SamplesNotInstalled overlay raised by the sample error handler, $PP.HISE_SAMPLE_DIALOG_SHOW_LOCATE_BUTTON$ -- the overlay is suppressed entirely when both buttons are disabled

### `HISE_SAMPLE_DIALOG_SHOW_LOCATE_BUTTON`

Shows the 'Locate Samples' button on the SamplesNotInstalled overlay in an exported plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Controls the locate button in the overlay that appears when the exported plugin cannot find its sample archive. When enabled, the user can point the plugin at an existing sample folder on first launch. When disabled, the plugin silently picks a sensible default location (the user documents folder on Windows, the music folder on macOS and Linux) and keeps using that until the location is changed manually in the settings window. The default message on the overlay also changes depending on which of the install and locate buttons are enabled.
> If both this and the install button are disabled, the SamplesNotInstalled overlay is suppressed completely.

**See also:** $API.ErrorHandler$ -- controls the locate button on the SamplesNotInstalled overlay raised by the sample error handler, $PP.HISE_SAMPLE_DIALOG_SHOW_INSTALL_BUTTON$ -- the overlay is suppressed entirely when both buttons are disabled, $PP.HISE_BROWSE_FOLDER_WHEN_RELOCATING_SAMPLES$ -- picker type used by the locate button is selected by this flag

### `HI_SUPPORT_FULL_DYNAMICS_HLAC`

Exposes the Full Dynamics sample encoding option in the exported plugin's sample install dialog.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | yes |

When enabled, the sample installer dialog inside the exported plugin shows the 'Sample bit depth' selector so the user can opt into the Full Dynamics HLAC encoding that preserves the original 24 bit dynamic range instead of the standard 16 bit path. The HISE IDE always shows this option. If disabled in an exported plugin, the install dialog falls back to the standard encoding with no user choice, which keeps the archive smaller and slightly speeds up decoding at the cost of extra quantisation noise.
> The HISE export dialog writes this flag automatically from the 'Support Full Dynamics' project setting, so you normally don't need to set it manually in the ExtraDefinitions field.

### `USE_FALLBACK_READERS_FOR_MONOLITH`

Uses a per-instance file handle for every monolith reader instead of memory mapping the sample archive.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Switches the streaming backend from memory-mapped monolith access to regular FileInputStream-based HLAC readers. The default picks memory mapping on 64 bit desktop builds and falls back to file handles on iOS and 32 bit builds where the address space is too small to map large sample sets. Enabling this explicitly forces the file handle path on every platform, which is useful when the plugin must run under sandboxing restrictions that block mmap, or when debugging a sample loading issue that seems to be related to the memory mapper.
> Turning this on costs one open file handle per monolith part per voice, so it can hit per-process file descriptor limits on large sample libraries.

**See also:** $MODULES.StreamingSampler$ -- forces the sampler's monolith reader to use file handles instead of memory mapping, $PP.HISE_LOAD_ENTIRE_SAMPLE_THRESHHOLD$ -- companion streaming-backend knob that controls when to bypass disk streaming entirely
