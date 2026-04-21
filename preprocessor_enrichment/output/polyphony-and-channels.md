---
title: Polyphony & Channels
description: Compile-time array sizes for voices, channels, and routing matrices — must match exactly between HISE, project DLLs, and exported plugins.
---

Preprocessors in this category fix the compile-time array sizes that HISE uses for voices, audio channels and routing matrices. They set the main plugin output channel count, the FX plugin channel count, the standalone output count, the project-wide channel ceiling, the maximum polyphonic voice count per sound generator and the maximum channel width for scriptnode frame containers. Raising any of them increases the memory footprint of every polyphonic voice or routing destination regardless of runtime usage, so only raise them for projects that genuinely need more than the default. These values must match exactly between the HISE build, any project DLL and the exported plugin, otherwise the voice-indexed and channel-indexed arrays disagree at runtime.

### `HISE_NUM_FX_PLUGIN_CHANNELS`

Number of audio channels exposed to the host when the project is exported as an effect plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `2` | no | no |

Controls the channel count that an exported FX plugin advertises to the DAW, which is the standard way to enable sidechain input or multi-channel effect processing (set to 4 for a stereo main plus stereo sidechain bus, 6 for 5.1, and so on). The value must be an even number and must not be smaller than the master container's routing matrix channel count; it may be larger, which lets you keep additional stereo pairs for hidden internal routing that the host never sees. Only affects effect plugin exports.
> Has no effect on instrument plugins or the standalone app, and is independent from the main plugin channel count used by instrument exports.

**See also:** $PP.NUM_MAX_CHANNELS$ -- must not exceed the project-wide channel ceiling

### `HISE_NUM_MAX_FRAME_CONTAINER_CHANNELS`

Upper channel limit for scriptnode frame processing containers.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `8` | no | no |

Frame processing containers in scriptnode produce one sample per channel at a time instead of processing in blocks, and their channel dispatch is resolved at compile time through a fixed set of template specialisations. This value caps how many channels those specialisations cover, so a frame container configured for more channels than the limit will fail to compile or fall back to the non-frame path. The default of 8 covers all common surround formats and only needs to be raised for unusual routing setups such as ambisonics or bespoke multichannel effects.
> Increasing this adds template instantiations and slightly grows compile time and binary size, so only raise it when you actually need wider frame containers.

**See also:** $SN.container.frame1_block$ -- frame container whose channel dispatch is bounded by this value, $SN.container.framex_block$ -- multichannel frame container whose maximum width is set by this value

### `HISE_NUM_PLUGIN_CHANNELS`

Number of output channels advertised by an exported instrument plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `2` | no | yes |

Defines the output bus width of the compiled instrument plugin and the destination channel count of the master routing matrix in plugin builds. The value must be even, a multiple of 2, and must not exceed the project-wide channel ceiling; pairing it with a correspondingly sized routing matrix in the master container lets you build multi-output instruments where each stereo pair lands on its own DAW bus. The HISE export dialog derives this value automatically from the master container's routing matrix (or clamps it to 2 when 'Force Stereo Output' is set), so it should rarely be set by hand.
> Manually overriding this in ExtraDefinitions bypasses the routing-matrix derivation and is only useful for edge cases such as exporting a plugin with more output channels than the master chain currently uses.

**See also:** $PP.NUM_MAX_CHANNELS$ -- must not exceed the project-wide channel ceiling, $PP.HISE_NUM_STANDALONE_OUTPUTS$ -- standalone output count defaults to this value

### `HISE_NUM_STANDALONE_OUTPUTS`

Number of output channels used when the project runs as a standalone application.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `2` | no | no |

Sets how many channels the standalone HISE app (and any exported standalone build) requests from the audio device and feeds to the master routing matrix. The value must be even and defaults to the main plugin channel count, which keeps standalone and plugin behaviour in sync for typical stereo projects. Raise this together with the plugin channel count when building a multi-output standalone instrument so that the extra buses reach the audio interface.
> When the standalone device settings and this value disagree, the standalone startup code will prompt to reset the saved audio configuration to match.

**See also:** $PP.HISE_NUM_PLUGIN_CHANNELS$ -- default tracks the plugin channel count so standalone and plugin builds stay aligned

### `NUM_MAX_CHANNELS`

Project-wide ceiling on the number of channels that the routing matrix and multichannel buffers can handle.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `16` | no | no |

Sets the fixed array size used throughout HISE for channel connections, routing matrices, microphone position bookkeeping and the multichannel audio buffer, so every container, effect and sampler instance is limited to this many channels regardless of its own configuration. The value must be a multiple of 2 and defaults to 16, which is enough for most surround and multi-mic sampler setups. Raise it (for example to 32) only when a project genuinely needs more than 8 stereo pairs, because the extra channels grow every per-channel array in the runtime.
> Must match between the HISE build and any project DLL or exported plugin; a mismatch corrupts routing-matrix state because the array sizes no longer line up.

**See also:** $MODULES.RouteFX$ -- routing-matrix channel count ceiling applied to the RouteFX module, $PP.HISE_NUM_PLUGIN_CHANNELS$ -- instrument plugin channel count is capped by this value, $PP.HISE_NUM_FX_PLUGIN_CHANNELS$ -- effect plugin channel count is capped by this value

### `NUM_POLYPHONIC_VOICES`

Compile-time upper bound on the number of simultaneously active voices per sound generator.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `256` | no | no |

Sets the fixed voice array size for every polyphonic sound generator, modulator chain, polyphonic envelope and polyphonic scriptnode state, so no sound generator can ever play more than this many voices regardless of its runtime voice limit. The default is 256 on desktop and 128 on iOS, which is the ceiling of the per-generator VoiceLimit parameter. Raising it increases the memory footprint of every polyphonic modulator and envelope and is only needed for extreme voice counts; the VoiceLimit parameter on each synth is the right place to tune per-patch polyphony, not this macro.
> Must match exactly between the HISE build and any project DLL, otherwise the voice-indexed arrays disagree in size and audio glitches or crashes occur when the DLL is loaded.

**See also:** $MODULES.StreamingSampler$ -- fixes the maximum voice count that the sampler can allocate, $MODULES.SynthGroup$ -- fixes the maximum voice count that the Synth Group can allocate
