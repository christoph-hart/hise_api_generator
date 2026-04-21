---
title: Backwards Compatibility
description: Flags that re-enable superseded HISE behaviours so shipped products keep sounding identical after a rebuild.
---

Preprocessors in this category restore historical HISE behaviours that were later fixed or improved. Each flag re-enables a specific quirk (old voice render order, squared modulation values, off-by-one block timestamps, the pre-HLAC monolith format and similar) so that a shipped product keeps sounding bit-exact when it is recompiled against a newer HISE build. They are not meant for new projects; the defaults are always the corrected behaviour. Several entries in this category are vestigial stubs kept only so that projects listing them in their Extra Definitions still compile.

### `HISE_PLAY_ALL_CROSSFADE_GROUPS_WHEN_EMPTY`

Plays every crossfade group at full gain when no crossfade modulator is connected.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Affects the sampler's group crossfade behaviour. When the crossfade modulation chain has no active modulator, the sampler returns a constant gain of 1.0 for every group instead of using the stored crossfade table value, so every group plays simultaneously. The default matches the original HISE behaviour and is almost always what you want, because it lets you audition grouped samples without having to wire up a modulator first.
> Disable this only if you have a legacy project that relied on the stored crossfade value being used when the chain is empty.

**See also:** $MODULES.StreamingSampler$ -- governs the crossfade group behaviour when no crossfade modulator is wired up, $API.Sampler$ -- scripted crossfade-group playback relies on the empty-chain fallback configured here, $PP.HISE_USE_WRONG_VOICE_RENDERING_ORDER$ -- related sampler backwards-compatibility switch

### `HISE_RAMP_RETRIGGER_ENVELOPES_FROM_ZERO`

Ramps monophonic envelopes down to zero before retriggering instead of jumping straight into the attack phase.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Changes how the RETRIGGER state works in the AHDSR, Simple Envelope and the equivalent scriptnode envelope nodes when they run in monophonic mode. The default behaviour immediately transitions from RETRIGGER into ATTACK and continues from the current envelope value. With this flag enabled, the envelope first ramps towards zero at a fixed rate of 0.005 per sample and only then enters the attack phase, which gives a slightly softer restart but introduces a small retrigger delay that scales with the current envelope level.
> Polyphonic mode is unaffected because a retrigger there allocates a new voice.

**See also:** $MODULES.AHDSR$ -- monophonic retrigger state takes the ramp-to-zero path instead of snapping to attack, $MODULES.SimpleEnvelope$ -- monophonic retrigger state takes the ramp-to-zero path instead of snapping to attack, $SN.envelope.ahdsr$ -- scriptnode envelope equivalent that follows the same retrigger rule, $SN.envelope.simple_ar$ -- scriptnode envelope equivalent that follows the same retrigger rule

### `HISE_USE_BACKWARDS_COMPATIBLE_TIMESTAMPS`

Subtracts one audio block from event timestamps generated on the audio thread for compatibility with older patches.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Adjusts the timestamp of artificial note-on and note-off events that scripts add through the Message and Synth scripting APIs while running on the audio thread. When enabled, the engine removes one buffer's worth of samples from the requested timestamp (clamped to zero) before queuing the event. This compensates for an old off-by-one-block scheduling behaviour so that presets built against the original timing keep sounding the same. Events triggered from other threads and artificial events created outside a MIDI callback are not affected.
> Turning this off gives you the newer, more accurate timestamp semantics but can shift the position of scripted notes by one block in existing projects.

**See also:** $API.Synth$ -- scheduled note-on and note-off timestamps are shifted by one block when this is enabled, $API.Message$ -- timestamps set through Message.setTimestamp are adjusted the same way

### `HISE_USE_WRONG_VOICE_RENDERING_ORDER`

Restores the pre-fix voice render order in which voice effects ran before the polyphonic gain modulation.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Affects the Sampler, Waveform Generator, Audio Looper and Synth Group. In older HISE builds these sound generators rendered their voice effect chain before applying the polyphonic gain, crossfade and group modulation values, which is the reverse of the other generators and produces a slightly different sound whenever the voice effect is non-linear (saturation, compression, tanh wave shaping). The default behaviour is the corrected order. Enabling this flag swaps back to the legacy order so that user presets that were voiced against the old output keep sounding the same.
> Only enable this if you are maintaining an existing product and need bit-exact compatibility with user presets built against the old order.

**See also:** $MODULES.StreamingSampler$ -- voice render order is reverted to the legacy pre-fix behaviour, $MODULES.WaveSynth$ -- voice render order is reverted to the legacy pre-fix behaviour, $MODULES.AudioLooper$ -- voice render order is reverted to the legacy pre-fix behaviour, $MODULES.SynthGroup$ -- voice render order is reverted to the legacy pre-fix behaviour, $PP.HISE_PLAY_ALL_CROSSFADE_GROUPS_WHEN_EMPTY$ -- related sampler backwards-compatibility switch

## Deprecated

These macros are still defined so old projects keep compiling, but no code reads them. Setting them has no effect.

### `HISE_SMOOTH_FIRST_MOD_BUFFER`

Historical switch for smoothing the first control-rate modulation buffer after a voice starts.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

The original intent was to suppress a one-block jump in the modulation signal at voice start by ramping the first rendered buffer instead of writing the initial value straight away. The macro is still defined but no code reads it anywhere, so toggling it has no effect on modulation behaviour or on audio output. It is kept around so that older user projects which list it in their ExtraDefinitions still compile.

### `HISE_USE_SQUARED_TIMEVARIANT_MOD_VALUES_BUG`

Historical switch for reproducing a bug that squared time-variant modulation values before applying them.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

The original purpose was to keep the sound of legacy patches that were tuned against an incorrect modulation path where time-variant modulator output was inadvertently multiplied by itself. The macro is still defined but no code path reads it anywhere, so enabling it does not reintroduce the bug. It is kept only so that projects which still list it in their ExtraDefinitions field keep compiling.

### `USE_OLD_MONOLITH_FORMAT`

Historical switch for loading samples from the pre-HLAC monolith container format.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

The original purpose was to fall back to the very first monolith container layout that HISE used before the current HLAC-based format was introduced. The macro is still defined with a hard-coded value of zero and no code reads it anywhere, so toggling it has no effect on the sampler or on how monolith files are decoded. It is kept only so that older user projects which list it in their ExtraDefinitions still compile.
