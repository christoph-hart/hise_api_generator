---
title: DSP & Filters
description: Module-specific DSP switches — delay buffer size, Curve EQ topology, filter modulation curve, async convolution damping, and neural network warmup.
---

Preprocessors in this category change the behaviour of specific DSP modules and scriptnode nodes. They set the maximum delay line size, swap the Curve EQ implementation between biquad and state-variable filters, shape how filter frequency modulation is applied, decide whether convolution damping updates run asynchronously, and configure the neural network warmup length. Each flag ties to a single module or node pair rather than being a project-wide knob, so its consequences are local and predictable. Expect a bit-exact sound shift on any patch that uses the affected processor when you change these.

### `HISE_LOG_FILTER_FREQMOD`

Applies a logarithmic skew to filter frequency modulation so the modulated cutoff tracks pitch more naturally.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

By default, any modulator feeding a filter's frequency input scales linearly between 20 Hz and 20 kHz, which makes the same modulation depth sound dramatic at low cutoffs and almost inaudible at high cutoffs. Enabling this flag wraps the frequency modulation in a log-style skew (the same perceptual curve used by the frequency knob itself), so an LFO or envelope moves the cutoff by roughly the same number of semitones regardless of where the base frequency sits. The skew is only applied when modulation is actually active, so a patch with no frequency modulator sounds identical either way.
> Left off by default because existing presets were voiced against the linear curve and flipping it changes the depth and shape of every filter modulation in the project.

**See also:** $MODULES.PolyphonicFilter$ -- applies the log-curve skew to the frequency modulation input, $MODULES.CurveEq$ -- applies the log-curve skew to the frequency modulation input of every band

### `HISE_MAX_DELAY_TIME_SAMPLES`

Maximum buffer size (in samples) for every delay line in the project.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `65536` | no | no |

Every delay line allocates a fixed power-of-two buffer at compile time, so this value defines the longest possible delay regardless of sample rate. The default of 65536 samples equals roughly 1.36 seconds at 48 kHz and drops to about 680 ms at 96 kHz. If your project uses long delays, big reverb tails or high sample rates, increase this to 131072, 262144 or 524288 to avoid the delay time being clamped at runtime.
> The value must be a power of two. Doubling it doubles the memory footprint of every delay instance, so don't set it higher than you actually need.

**See also:** $MODULES.Delay$ -- sets the internal delay line buffer size that caps the maximum delay time, $SN.core.fix_delay$ -- scriptnode delay line that uses the same compile-time buffer size

### `HISE_NEURAL_NETWORK_WARMUP_TIME`

Number of silent samples that the neural network node processes on reset to flush its internal state.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | yes | no |

Whenever a voice is started or the network is reset, the node feeds this many zero-valued samples through the model before real audio arrives. This warms up any recurrent layers and IIR-style history inside the network so the first output sample does not carry the noise or click that an uninitialised model produces. Values between 128 and 2048 are typical; larger networks with long temporal memory need higher values, whereas stateless feedforward models can leave it at zero.
> Read from the project's Extra Definitions at runtime, so changing the value in the Preferences window and recompiling the scriptnode network is enough, no full HISE rebuild required.

**See also:** $SN.math.neural$ -- warmup sample count used when the neural node resets, $PP.HISE_INCLUDE_RT_NEURAL$ -- only takes effect in builds where the RTNeural inference library is compiled in

### `HISE_UPDATE_CONVOLUTION_DAMPING_ASYNC`

Recomputes the convolution Damping filter asynchronously so UI drags stay smooth.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Changing the Damping parameter of a convolution reverb applies a one-pole low-pass to the impulse response, which is an expensive operation. With this flag on, the recomputation is dispatched to the worker thread so a slider drag or automation stream can keep feeding new values without stalling the UI or glitching the audio. Loading an impulse response or changing its sample range always stays synchronous, regardless of this setting.
> Disable only if you need strict ordering when a script sets Damping back-to-back with an IR swap or range change, because the async path can otherwise apply the damping after the next IR has already loaded.

**See also:** $MODULES.Convolution$ -- Damping parameter changes are dispatched to the worker thread instead of stalling the audio thread, $SN.filters.convolution$ -- scriptnode convolution node that uses the same damping-update path

### `HISE_USE_SVF_FOR_CURVE_EQ`

Swaps the biquad implementation inside the Parametriq EQ for state-variable filters.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

The Parametriq EQ uses stock biquad coefficients for every band by default, which sound fine on static settings but produce audible zipper noise when the frequency, gain or Q of a band is automated or scripted in real time. Enabling this flag switches every band to the state-variable filter topology (the same one exposed as filters.svf_eq in scriptnode), which is zipper-free under modulation and additionally gives the LowPass and HighPass bands a working Q parameter instead of the fixed one-pole response. The static sound is slightly different from the biquad version, so existing mix references will shift.
> Must be set in both the HISE build and the exported plugin's Extra Definitions, because the filter type is baked into the binary at compile time.

**See also:** $MODULES.CurveEq$ -- every band switches from biquad coefficients to SVF topology, $SN.filters.svf_eq$ -- scriptnode node that uses the same SVF topology by default

### `USE_MOD2_WAVETABLESIZE`

Fast-path wavetable playback that requires power-of-two cycle lengths in every .hwt file.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

When enabled, the wavetable synthesiser indexes its buffer with a bitmask wrap instead of a modulo and a branch, which is the hot inner loop during every voice render and noticeably cheaper on the audio thread. Loading a wavetable whose cycle length is not a power of two logs an error and plays back incorrectly. Since HISE 3.5 the wavetable converter produces power-of-two cycles by default, so this only bites for projects that still ship legacy .hwt files.
> Disable (set to 0) only if you need to keep playing pre-3.5 wavetables and can't reconvert them. The slower inner loop is the price of that compatibility.

**See also:** $MODULES.WavetableSynth$ -- requires every wavetable cycle length to be a power of two, $PP.HISE_INCLUDE_LORIS$ -- Loris-based cycle extraction produces power-of-two wavetables that rely on this fast path

## Deprecated

These macros are still defined so old projects keep compiling, but no code reads them. Setting them has no effect.

### `MIN_FILTER_FREQ`

Historical knob for the lowest cutoff frequency any filter can be tuned to.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `20` | no | no |

The original intent was to raise or lower the hard floor that every filter clamps its frequency parameter against so that projects working below 20 Hz could still open the cutoff all the way down. The macro is still defined but the filter limit values are hard-coded to 20 Hz in the same header, so setting it has no effect on the audible frequency range. It is kept around only so that older user projects which list it in their ExtraDefinitions still compile.
