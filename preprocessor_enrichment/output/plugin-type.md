---
title: Plugin Type
description: Plugin type and host bus configuration — instrument vs effect, audio input routing, mono layout, and FX-build sound generator handling.
---

Preprocessors in this category tell the compiled plugin what kind of thing it is and how it connects to the host. They control whether the plugin is an instrument or an effect, whether an instrument build accepts audio input on its master chain, whether an effect build advertises a mono bus layout alongside stereo, and whether child sound generators keep running inside an effect plugin so that their modulation signals are still rendered. The HISE export dialog writes most of these flags automatically from project settings, so they rarely need to be set by hand in the Extra Definitions field. Manual overrides are only useful for edge cases such as multi-bus builds or specialised hybrid plugins.

### `FORCE_INPUT_CHANNELS`

Routes the host audio input into the master chain of an instrument plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

By default an instrument plugin only produces audio from its sound generators and ignores any audio coming from the host. Setting this to 1 adds a stereo input bus that feeds directly into the top of the master chain, so the master effect chain processes the incoming host audio alongside the generated instrument output. Use this when you need an instrument plugin that also reacts to audio on the track, for example a sampler with a built-in input effect path or a hybrid instrument/effect hosted on an audio track.
> Only meaningful in stereo instrument builds. It is automatically ignored when the plugin is configured for more than two output channels, and it has no effect on effect plugin exports (which always have an input bus).

**See also:** $PP.PROCESS_SOUND_GENERATORS_IN_FX_PLUGIN$ -- sibling FX plugin bus-configuration switch

### `HI_SUPPORT_MONO_CHANNEL_LAYOUT`

Makes an exported effect plugin accept a mono track configuration in addition to stereo.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | yes |

Only relevant when the project is exported as an effect plugin. When enabled, the plugin reports both a mono-in/mono-out and a stereo-in/stereo-out bus layout to the host, so it can be inserted on mono tracks as well as stereo tracks. When disabled, the plugin advertises stereo only and hosts will either refuse to load it on a mono track or silently wrap it in an adapter.
> The HISE export dialog writes this flag automatically from the 'Support Mono FX' project setting, so you normally don't need to set it manually in the ExtraDefinitions field.

**See also:** $PP.HI_SUPPORT_MONO_TO_STEREO$ -- companion flag that extends the mono layout with a mono-in/stereo-out bus

### `HI_SUPPORT_MONO_TO_STEREO`

Advertises a mono-input / stereo-output bus layout on an effect plugin with mono support enabled.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Extends the mono track support so that the plugin accepts a mono input feeding a stereo output, rather than only mono-in/mono-out and stereo-in/stereo-out. The incoming mono signal is duplicated to both channels before processing, which lets a naturally stereo effect (reverb, ping-pong delay, stereo widener) be inserted on a mono source without the host summing the output back to mono. Requires the mono channel layout support to also be enabled.
> Do not set this flag by hand. Use the 'Force Stereo Output' project setting together with 'Support Mono FX' instead, because setting the preprocessor manually causes FL Studio VST3 builds to collapse the stereo output back to mono.

**See also:** $PP.HI_SUPPORT_MONO_CHANNEL_LAYOUT$ -- requires the mono channel layout support to be enabled as well

### `PROCESS_SOUND_GENERATORS_IN_FX_PLUGIN`

Keeps child sound generators running inside an exported FX plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | yes |

Only relevant when the project is exported as an effect plugin. If enabled, every sound generator in the master chain is still rendered so that global modulators, macro modulation sources, LFOs and envelopes that feed modulation slots on the effect chain keep producing their values. If disabled, only the effect chain itself is processed which saves a bit of CPU but breaks any modulation that originates from a sound generator.
> The HISE export dialog writes this flag automatically based on the 'Process Sound Generators in FX Plugin' checkbox, so you normally don't need to set it manually in the ExtraDefinitions field.

**See also:** $PP.FORCE_INPUT_CHANNELS$ -- sibling FX plugin bus-configuration switch, $PP.HISE_ENABLE_MIDI_INPUT_FOR_FX$ -- MIDI input has to be enabled on an FX plugin before keeping sound generators alive delivers any MIDI-triggered modulation
