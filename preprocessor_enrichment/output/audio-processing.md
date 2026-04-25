---
title: Audio Processing
description: Block-level audio engine knobs — modulation raster, processing block size, voice culling, tempo-sync range, and suspended-voice handling.
---

Preprocessors in this category change how the audio engine renders each block. They cover the control-rate modulation raster, the maximum processing block size that downstream DSP code assumes, the silence-detection threshold for voice culling, the tempo value range available to every tempo-synced parameter, and the handling of suspension tails when voices are killed. Most entries are bit-exact switches that affect the sound or the CPU cost of every voice, so changing them ripples through the entire project. Before touching any of these, confirm that the trade-off is worth the reduction in preset compatibility with the default build.

### `HISE_EVENT_RASTER`

Downsampling factor for the modulation and event-timestamp raster.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `8` | no | no |

Sets the divisor that every modulator, envelope and scriptnode modchain uses to step down from the audio rate, and also defines the sample grid that MIDI note, controller and timer events get aligned to inside a block. The default is 8 for instrument plugins (modulation runs at sampleRate / 8, which is about 5.5 kHz at 44.1 kHz) and 1 for effect plugins where no downsampling happens. Setting it to 4, 2 or 1 in instrument projects gives finer modulation resolution at the cost of proportionally more CPU in every modulator and scriptnode modchain, which is the standard workaround for LFO aliasing above roughly 30 Hz.
> The host buffer size must be an integer multiple of this value or the engine refuses to render. Set it consistently in both the HISE build and the exported plugin, and keep it a power of two (1, 2, 4 or 8) to stay compatible with the event scheduler.

**See also:** $MODULES.LFO$ -- LFO accuracy above roughly 30 Hz improves when this divisor is lowered, $API.Engine.getControlRateDownsamplingFactor$ -- Engine.getControlRateDownsamplingFactor returns this value at runtime, $API.Synth$ -- sample-accurate timer events on the synth are rastered to this grid, $SN.container.modchain$ -- children of a modchain run at sampleRate divided by this factor, $PP.HISE_MAX_PROCESSING_BLOCKSIZE$ -- maximum block size must stay a multiple of this raster, $PP.HISE_COMPLAIN_ABOUT_ILLEGAL_BUFFER_SIZE$ -- triggers a user-facing overlay when the host buffer size is not a multiple of this raster

### `HISE_MAX_PROCESSING_BLOCKSIZE`

Upper ceiling for the internal audio block size used by the rendering loop.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `512` | no | no |

Caps the largest block size that the engine will process in a single pass; if the host calls with a bigger buffer, the render callback splits it into chunks no larger than this value before dispatching to the voice renderer and effect chain. Bigger values mean fewer dispatch overheads but also grow every internal scratch buffer that is sized to the maximum block, so very high ceilings waste memory and can introduce streaming engine edge cases. The default of 512 is the sweet spot for the built-in filter and polyphonic effect paths; the setMaximumBlockSize scripting method clamps its argument to the range 16 to this value.
> Keep this as a power of two and at least equal to the event raster, otherwise block splitting will not align cleanly with modulation updates.

**See also:** $API.Engine.setMaximumBlockSize$ -- Engine.setMaximumBlockSize clamps its argument to this ceiling, $MODULES.PolyphonicFilter$ -- filter quality and internal scratch buffers are sized to this block cap, $PP.HISE_EVENT_RASTER$ -- block size must stay a multiple of the event raster, $PP.HISE_COMPLAIN_ABOUT_ILLEGAL_BUFFER_SIZE$ -- illegal buffer sizes caught by the raster check raise the overlay message when this flag is on

### `HISE_SILENCE_THRESHOLD_DB`

Threshold in negative decibels below which the engine treats a parameter value or envelope level as silent.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `60` | no | no |

Sets the gain value that parameter smoothers, the polyphonic envelope decay stage and the sampler voice crossfade logic use to decide that a ramp or decay has effectively reached its target. The stored value is interpreted as the negative dB, so the default of 60 means anything below -60 dB counts as silence. Lowering it (for example to 80 or 90) makes envelope decays run closer to true zero at the cost of a slightly longer voice tail; raising it shortens tails but can cut off quiet release material before it has finished. The value is a compile-time constant baked into every generator that uses the silence test.
> The voice kill-fade-out time is still calibrated against a fixed -60 dB target regardless of this setting, so lowering the threshold can extend the actual kill fade beyond the scripted value.

**See also:** $MODULES.AHDSR$ -- envelope decay stage transitions to sustain or idle when the value falls below this threshold, $MODULES.StreamingSampler$ -- voice crossfade smoothing uses this threshold to decide when interpolation can stop

### `HISE_SUSPENSION_TAIL_MS`

Length in milliseconds that an effect keeps rendering after its input has gone silent before suspending itself.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `500` | yes | no |

Defines the tail window that every master and voice effect with suspend-on-silence enabled waits out before freezing its processing and outputting silence directly. The value is converted into a callback count based on the current sample rate and block size, so longer tails cover reverbs and long delays whose output keeps sounding well after the input stops, while shorter tails save more CPU on dry effects. The default of 500 ms is a compromise that works for most mixed effect chains; raise it to 2000 or higher for convolution reverbs with long impulse responses, lower it towards 100 for dry clippers or EQs.
> Read from the project's Extra Definitions at runtime, so changing the value in the Preferences window takes effect on the next prepareToPlay without a full HISE rebuild.

**See also:** $MODULES.Convolution$ -- reverb tail needs a suspension window long enough to cover the impulse response, $MODULES.Delay$ -- delay tail needs a suspension window at least as long as the maximum delay time, $API.Effect.isSuspendedOnSilence$ -- isSuspendedOnSilence flag on effects uses this window to decide when to freeze processing

### `HISE_USE_EXTENDED_TEMPO_VALUES`

Adds longer tempo divisions (up to eight bars) to every tempo-synced parameter in the project.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

The built-in tempo list that feeds every TempoSync slider, the arpeggiator's Tempo parameter and the `Engine.getTempoInMilliSeconds` / `TransportHandler` scripting APIs only goes up to a whole note by default. Enabling this flag prepends five longer values (EightBar, SixBar, FourBar, ThreeBar, TwoBars) to the front of the list, which is useful for slowly evolving ambient patches or long arpeggiator phrases.
> Turning this on shifts every existing tempo index by 5, so any user preset that stored a tempo as an integer index before the change will map to a different note value after recompiling. The flag must be set consistently for both the HISE build and the exported plugin, otherwise stored indices will not round-trip.

**See also:** $MODULES.Arpeggiator$ -- exposes the extended divisions on its Tempo parameter, $API.Engine$ -- tempoIndex arguments on getTempoInMilliSeconds and related methods shift by five, $API.TransportHandler$ -- beat-grid callbacks use the extended tempo enum

### `HI_DONT_SEND_ATTRIBUTE_UPDATES`

Suppresses the async UI notification when a script changes a module parameter in an exported plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Every call to a scripted setAttribute normally posts an async message so that any attached UI controls and plotters update to reflect the new value. Enabling this flag replaces that notification with a silent write, which can noticeably reduce message-thread pressure in plugins that drive parameters from tight control-rate scripts. UI controls bound directly to those parameters will stop updating visually until the user interacts with them again or the script pushes an explicit repaint. Only applies to exported plugin builds; the HISE IDE always sends notifications so that parameter edits stay visible in the editor.
> Only enable this when scripted parameter changes are verifiably clogging the message thread, because the lost UI feedback will confuse users interacting with automated controls.

### `USE_HARD_CLIPPER`

Replaces the soft output safety clip with a hard brickwall limit at the final render stage.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Controls the very last step in the master render callback where output samples are kept inside a sane range. With the flag off, iOS builds still clip to the range from -1.0 to 1.0 to avoid the nasty digital distortion that mobile audio hardware produces for out-of-range samples, and desktop builds pass the signal through untouched. With the flag on, every platform receives a hard brickwall clip at unity gain regardless of the device, which is useful for defensive plugin builds that must never overshoot full scale. The clip is always at 0 dBFS and is not configurable.
> A hard clip adds harmonic distortion to every sample above 1.0, so only enable this if you actually need the safety net. Use a dedicated limiter on the master chain for musical peak control.

## Deprecated

These macros are still defined so old projects keep compiling, but no code reads them. Setting them has no effect.

### `HISE_ENABLE_FULL_CONTROL_RATE_PITCH_MOD`

Historical switch for retaining full-resolution pitch modulation on the control-rate path.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

The original intent was to keep pitch modulation at audio rate even when the rest of the modulation system ran at the reduced control rate, so that vibrato and pitch-envelope detail did not get stepped by the downsampling. The macro is still defined with a hard-coded value of zero and no code reads it anywhere, so toggling it has no effect on the pitch modulation path or on audio output. It is kept only so that older user projects which list it in their ExtraDefinitions field still compile.
