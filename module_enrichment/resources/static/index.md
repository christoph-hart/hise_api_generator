---
title: Audio Modules
description: Reference for all HISE audio modules — sound generators, modulators, effects, and MIDI processors

guidance:
  summary: >
    Complete reference for all HISE processor types. Sound Generators:
    StreamingSampler (disk-streaming sampler), WaveSynth (basic waveforms),
    WavetableSynth, SineSynth (FM/additive), AudioLooper, SynthGroup,
    ModulatorSynthChain. Modulators: AhdsrEnvelope, SimpleEnvelope, LFO,
    Velocity, MidiController, Random, KeyNumber, GlobalModulator.
    Effects: PolyphonicFilter, CurveEq, SimpleReverb, Convolution, Delay,
    Chorus, PhaseFX, Saturator, SimpleGain, SlotFX, Dynamics, Analyser,
    ShapeFX. MIDI Processors: ScriptProcessor, Transposer, MidiMuter.
    Each entry includes all parameters, usage notes, and per-voice vs
    master placement guidance.
  concepts:
    - audio modules reference
    - processor types
    - sound generators
    - modulators
    - effects
    - MIDI processors
  complexity: advanced
---

Audio modules are the building blocks of every HISE instrument. They form a tree structure rooted at a top-level Container (ModulatorSynthChain), with each module processing audio, MIDI, or control signals.

## Module Types

**[Sound Generators](/v2/reference/audio-modules/sound-generators/)** produce audio output and form the backbone of the signal chain. They host MIDI processor, modulation, and effect chains.

**[MIDI Processors](/v2/reference/audio-modules/midi-processors/)** transform, filter, or generate MIDI events before they reach the sound generator's voice rendering.

**[Modulators](/v2/reference/audio-modules/modulators/)** generate control signals in the range 0.0 to 1.0 that modulate gain, pitch, and effect parameters. Three subtypes cover different timing needs: voice start, time variant, and envelope.

**[Effects](/v2/reference/audio-modules/effects/)** process audio after generation. They operate at master, monophonic, or polyphonic scope depending on whether they need per-voice state.

## Reading the Pseudocode

This documentation uses interactive pseudocode blocks to describe signal flow and processing models. Highlighted terms are hoverable - they show descriptions, parameter ranges, and implementation details in a tooltip.

::signal-path
---
glossary:
  parameters:
    Frequency:
      desc: "A module parameter. Blue terms are configurable values exposed via setAttribute()."
      range: "20 - 20000 Hz"
      default: "1000 Hz"
  functions:
    processAudio:
      desc: "A processing function. Orange terms describe computation steps performed by the module."
    applyFilter:
      desc: "Functions can include a detail field with formulas or mode-specific behaviour."
      detail: |
        LowPass:  attenuate frequencies above cutoff
        HighPass: attenuate frequencies below cutoff
        BandPass: attenuate frequencies outside band
  modulations:
    GainMod:
      desc: "A modulation signal. Green terms represent control signals from modulators."
      scope: "per-voice"
---

```
// Example pseudocode - hover the highlighted terms
output = processAudio(input, Frequency)
output = applyFilter(output)
output = output * GainMod
```

::

::tip{title="About this Pseudocode"}
The pseudocode shows the abstract processing model, not literal C++ or HiseScript code. Each type's index page contains pseudocode blocks specific to that module type.
::

## Common Concepts

All audio modules share these features inherited from the `Processor` base class.

### Module Tree

Modules form a hierarchical tree. A sound generator contains MIDI processors, modulators, and effects as child processors. Container modules (ModulatorSynthChain, SynthGroup) hold multiple sound generators in parallel.

### Processor ID

Every module has a unique string ID used to identify it in the module tree and reference it from scripts. Changing a Processor ID will break existing script references.

::tip{title="IDE Workflow"}
Right-click a module's top bar in the HISE IDE to copy its XML to the clipboard or generate a script reference declaration that you can paste into a Script Processor's `onInit` callback.
::

### Parameters

Modules expose numbered parameters via `setAttribute()` / `getAttribute()`. Each module type defines its own parameter enum. Parameters accept float values and can be automated by the host DAW.

### Bypass

Any module can be bypassed via `setBypassed()`. Effects use a soft bypass with a short crossfade to avoid clicks.

### State Persistence

Module state can be exported as XML (ValueTree) and restored. From scripts, use `Processor.exportState()` and `Processor.restoreState()` with base64-encoded strings to save and restore processor snapshots.

### Scripting Access

Modules are accessed from HiseScript using typed `get*()` methods on the `Synth` namespace. These must be called in `onInit` and stored as `const var` for reuse across callbacks:

```javascript
// Base class references (onInit only)
const var fx      = Synth.getEffect("Delay1");
const var mod     = Synth.getModulator("LFO1");
const var mp      = Synth.getMidiProcessor("Arpeggiator1");
const var child   = Synth.getChildSynth("SubBass");
const var sampler = Synth.getSampler("MainSampler");

// Typed interface references for special data access
const var table   = Synth.getTableProcessor("VeloTable");
const var audio   = Synth.getAudioSampleProcessor("Looper1");
const var slider  = Synth.getSliderPackProcessor("LFOSteps");
const var matrix  = Synth.getRoutingMatrix("MasterChain");
```

Use `setAttribute()` to change parameters, `setIntensity()` / `setBipolar()` for modulator-specific properties (see [Modulators](/v2/reference/audio-modules/modulators/#common-parameters)), and `setBypassed()` to toggle bypass state.

## Categories

An overview of all audio modules grouped by functional category. Modules may appear in more than one category.

---

### Container

Modules that hold and combine other sound generators.

- [Container](/v2/reference/audio-modules/sound-generators/synthchain): A container for other Sound generators.
- [Synthesiser Group](/v2/reference/audio-modules/sound-generators/synthgroup): A container for synthesisers that share common modulation, with optional FM synthesis and unison detune/spread.
- [Global Modulator Container](/v2/reference/audio-modules/sound-generators/globalmodulatorcontainer): A container that processes Modulator instances that can be used at different locations.
- [Send Container](/v2/reference/audio-modules/sound-generators/sendcontainer): A signal chain tool that receives the signal from a Send FX and applies its own effect chain.
- [Macro Modulation Source](/v2/reference/audio-modules/sound-generators/macromodulationsource): A container that hosts modulator chains whose output drives the macro control system.

---

### Custom

Modules that run user-defined DSP logic via scriptnode networks, compiled C++ code, or HiseScript callbacks. Contains sound generators, MIDI processors, effects, and modulators.

#### Hardcoded modules

- [Hardcoded Master FX](/v2/reference/audio-modules/effects/master/hardcodedmasterfx): Runs a compiled C++ DSP network as a master effect, with dynamic parameter and complex data exposure from the network.
- [Hardcoded Polyphonic FX](/v2/reference/audio-modules/effects/polyphonic/hardcodedpolyphonicfx): Runs a compiled C++ DSP network as a polyphonic effect, processing each voice independently with per-voice state.
- [Hardcoded Synthesiser](/v2/reference/audio-modules/sound-generators/hardcodedsynth): Runs a compiled C++ DSP network as a polyphonic sound generator with per-voice processing and full modulator chain support.
- [Hardcoded Envelope Modulator](/v2/reference/audio-modules/modulators/envelope/hardcodedenvelopemodulator): Runs a compiled C++ DSP network as a polyphonic envelope modulator with per-voice state and voice management.
- [Hardcoded Time Variant Modulator](/v2/reference/audio-modules/modulators/time-variant/hardcodedtimevariantmodulator): Runs a compiled C++ DSP network as a monophonic time-variant modulator with dynamic parameters.

#### Scriptnode modules

- [Script Processor](/v2/reference/audio-modules/midi-processors/scriptprocessor): The main scripting interface for MIDI processing, UI creation, and plugin control via the HiseScript API.
- [Script FX](/v2/reference/audio-modules/effects/master/scriptfx): Processes audio through a scriptnode DSP network as a master effect, with scriptable parameters and complex data routing.
- [Polyphonic Script FX](/v2/reference/audio-modules/effects/polyphonic/polyscriptfx): Processes each voice independently through a scriptnode DSP network, with per-voice state and polyphonic modulation support.
- [Scriptnode Synthesiser](/v2/reference/audio-modules/sound-generators/scriptsynth): Generates polyphonic audio from a scriptnode DSP network, with per-voice processing and full modulator chain support.
- [Script Envelope Modulator](/v2/reference/audio-modules/modulators/envelope/scriptenvelopemodulator): Generates a polyphonic envelope signal from a scriptnode DSP network, with per-voice state and voice kill detection.
- [Script Time Variant Modulator](/v2/reference/audio-modules/modulators/time-variant/scripttimevariantmodulator): Generates a continuous monophonic modulation signal from a scriptnode DSP network or HiseScript timer callback.
- [Script Voice Start Modulator](/v2/reference/audio-modules/modulators/voice-start/scriptvoicestartmodulator): Computes a per-voice modulation value at note-on using a HiseScript callback, for custom velocity curves or scripted voice logic.

#### Custom Utility modules

- [Scriptnode Voice Killer](/v2/reference/audio-modules/modulators/envelope/scriptnodevoicekiller): Monitors a scriptnode envelope's gate signal and terminates voices when the gate closes, required for voice management in scriptnode-based envelopes.
- [Silent Synth](/v2/reference/audio-modules/sound-generators/silentsynth): A silent sound generator that routes signals through its effect chain without producing audio of its own.

---

### Note Processing

MIDI processors that transform, filter, or react to incoming note events. Contains MIDI processors and modulators.

- [MIDI CC to Note Generator](/v2/reference/audio-modules/midi-processors/cc2note): Turns a selected MIDI CC into a note trigger, useful for controller-driven drum or round-robin triggering.
- [MIDI Channel Filter](/v2/reference/audio-modules/midi-processors/channelfilter): Filters incoming MIDI by channel, with optional MPE start and end channel ranges for MPE setups.
- [MIDI Channel Setter](/v2/reference/audio-modules/midi-processors/channelsetter): Rewrites the MIDI channel for all incoming messages, useful for routing or consolidating controllers.
- [Choke Group Processor](/v2/reference/audio-modules/midi-processors/chokegroupprocessor): Kills active notes when another choke group processor in the same group receives a note-on, useful for hi-hat and mute group behavior.
- [Notenumber Modulator](/v2/reference/audio-modules/modulators/voice-start/keynumber): Creates a modulation value based on the MIDI note number, with optional table mapping for custom response curves.
- [Legato with Retrigger](/v2/reference/audio-modules/midi-processors/legatowithretrigger): Monophonic legato processor that retriggers the previous note after a release, useful for lead lines and expressive legato phrasing.
- [Release Trigger](/v2/reference/audio-modules/midi-processors/releasetrigger): Release trigger generator that replays notes on key-up with velocity scaled by a time-based attenuation curve.
- [Transposer](/v2/reference/audio-modules/midi-processors/transposer): Transposes incoming MIDI note-on events by a fixed number of semitones for quick key changes or interval shifts.
- [Velocity Modulator](/v2/reference/audio-modules/modulators/voice-start/velocity): Creates a modulation value from the MIDI velocity of incoming note messages, with optional table mapping and decibel conversion.

---

### Input

Modulators that convert external events like MIDI or MPE into modulation signals.

- [Array Modulator](/v2/reference/audio-modules/modulators/voice-start/arraymodulator): Creates a modulation signal from a slider pack array indexed by MIDI note number, allowing per-note modulation values.
- [Notenumber Modulator](/v2/reference/audio-modules/modulators/voice-start/keynumber): Creates a modulation value based on the MIDI note number, with optional table mapping for custom response curves.
- [MPE Modulator](/v2/reference/audio-modules/modulators/envelope/mpemodulator): Creates per-voice modulation from MPE pressure, slide, or glide gestures with adjustable smoothing and default values.
- [Midi Controller](/v2/reference/audio-modules/modulators/time-variant/midicontroller): Creates a modulation signal from MIDI CC messages with adjustable smoothing and optional table mapping for custom response curves.
- [Pitch Wheel Modulator](/v2/reference/audio-modules/modulators/time-variant/pitchwheel): Creates a monophonic modulation signal from the pitch wheel, with smoothing to reduce stepping artifacts.
- [Velocity Modulator](/v2/reference/audio-modules/modulators/voice-start/velocity): Creates a modulation value from the MIDI velocity of incoming note messages, with optional table mapping and decibel conversion.

---

### Sequencing

MIDI processors that generate or play back note sequences.

- [Arpeggiator](/v2/reference/audio-modules/midi-processors/arpeggiator): Configurable arpeggiator with tempo sync, direction, octave range, and per-step sliders for melodic sequencing and rhythm generation.
- [Audio Loop Player](/v2/reference/audio-modules/sound-generators/audiolooper): A single-file audio player with looping, pitch tracking, tempo sync, and reverse playback.
- [MidiMetronome](/v2/reference/audio-modules/effects/master/midimetronome): A metronome that produces click sounds synchronized to a connected MIDI player's tempo.
- [MIDI Player](/v2/reference/audio-modules/midi-processors/midiplayer): Plays MIDI sequences with transport controls, loop regions, and multi-track support for piano roll and step sequencer overlays.

---

### Oscillator

Modules that generate audio or modulation signals from oscillators or synthesis algorithms. Contains sound generators and modulators.

- [LFO Modulator](/v2/reference/audio-modules/modulators/time-variant/lfo): Generates a periodic modulation signal with multiple waveform types, tempo sync, and an optional step sequencer mode.
- [Noise Generator](/v2/reference/audio-modules/sound-generators/noise): A white noise generator useful for layering, testing signal flow, or as a modulation source.
- [Sine Wave Generator](/v2/reference/audio-modules/sound-generators/sinesynth): A lightweight sine wave generator for FM synthesis, additive synthesis, or adding subtle harmonics to other sounds.
- [Synthesiser Group](/v2/reference/audio-modules/sound-generators/synthgroup): A container for synthesisers that share common modulation, with optional FM synthesis and unison detune/spread.
- [Waveform Generator](/v2/reference/audio-modules/sound-generators/wavesynth): A waveform generator based on BLIP synthesis of common synthesiser waveforms.
- [Wavetable Synthesiser](/v2/reference/audio-modules/sound-generators/wavetablesynth): A two-dimensional wavetable synthesiser that morphs between waveforms using a table index and supports audio file resynthesis.

---

### Sample Playback

Modules that play back audio samples.

- [Audio Loop Player](/v2/reference/audio-modules/sound-generators/audiolooper): A single-file audio player with looping, pitch tracking, tempo sync, and reverse playback.
- [Sampler](/v2/reference/audio-modules/sound-generators/streamingsampler): A disk-streaming sampler with sample maps, round robin, crossfade groups, and timestretching.

---

### Generator

Modulators that create modulation signals internally, such as envelopes and LFOs. Contains modulators and MIDI processors.

- [AHDSR Envelope](/v2/reference/audio-modules/modulators/envelope/ahdsr): An AHDSR envelope with adjustable curve shapes, optional downsampling for CPU savings, and per-voice modulation of all time parameters.
- [Arpeggiator](/v2/reference/audio-modules/midi-processors/arpeggiator): Configurable arpeggiator with tempo sync, direction, octave range, and per-step sliders for melodic sequencing and rhythm generation.
- [Constant](/v2/reference/audio-modules/modulators/voice-start/constant): Creates a constant modulation signal (1.0) that can be used as a fixed gain offset or modulation source.
- [Flex AHDSR Envelope](/v2/reference/audio-modules/modulators/envelope/flexahdsr): A more complex AHDSR envelope with draggable curves and multiple playback modes.
- [LFO Modulator](/v2/reference/audio-modules/modulators/time-variant/lfo): Generates a periodic modulation signal with multiple waveform types, tempo sync, and an optional step sequencer mode.
- [MIDI Player](/v2/reference/audio-modules/midi-processors/midiplayer): Plays MIDI sequences with transport controls, loop regions, and multi-track support for piano roll and step sequencer overlays.
- [Random Modulator](/v2/reference/audio-modules/modulators/voice-start/random): Generates a random value at each voice start, with optional table mapping for custom probability distributions.
- [Simple Envelope](/v2/reference/audio-modules/modulators/envelope/simpleenvelope): A lightweight two-stage envelope with attack and release, supporting linear or exponential curves.
- [Table Envelope](/v2/reference/audio-modules/modulators/envelope/tableenvelope): An envelope with fully customizable attack and release shapes drawn as lookup tables.

---

### Filter

Effects that shape the frequency spectrum of the audio signal.

- [Parametriq EQ](/v2/reference/audio-modules/effects/master/curveeq): A parametric equalizer with unlimited filter bands and an FFT spectrum display for visual feedback.
- [Harmonic Filter](/v2/reference/audio-modules/effects/polyphonic/harmonicfilter): Polyphonic peak filters tuned to the root frequency and harmonics of each voice, with crossfadeable A/B slider pack configurations.
- [Harmonic Filter Monophonic](/v2/reference/audio-modules/effects/monophonic/harmonicfiltermono): Monophonic peak filters tuned to the root frequency and harmonics of the last played note, with crossfadeable A/B configurations.
- [Filter](/v2/reference/audio-modules/effects/polyphonic/polyphonicfilter): Applies monophonic or polyphonic filtering with modulatable frequency, gain, and resonance, supporting multiple filter types.

---

### Dynamics

Effects that shape the amplitude or add distortion and saturation.

- [Dynamics](/v2/reference/audio-modules/effects/master/dynamics): A dynamics processor combining gate, compressor, and limiter based on chunkware's SimpleCompressor algorithms.
- [Polyshape FX](/v2/reference/audio-modules/effects/polyphonic/polyshapefx): A polyphonic waveshaper with multiple shaping modes, table-based curves, and optional oversampling.
- [Saturator](/v2/reference/audio-modules/effects/master/saturator): Applies waveshaping saturation with pre/post gain controls and wet/dry mix.
- [Shape FX](/v2/reference/audio-modules/effects/master/shapefx): Waveshaper effect with selectable shaping modes, bias, filters, and oversampling, suitable for distortion and tone shaping with optional autogain.

---

### Delay

Effects based on delayed signal copies, including chorus and phaser.

- [Chorus](/v2/reference/audio-modules/effects/master/chorus): Stereo chorus effect with modulated delay lines for thickening and movement.
- [Delay](/v2/reference/audio-modules/effects/master/delay): Stereo delay with independent left and right times, feedback, and filtering, with optional tempo sync for rhythmic echo effects.
- [Phase FX](/v2/reference/audio-modules/effects/master/phasefx): Phaser effect using modulated allpass filters for sweeping frequency notches.

---

### Reverb

Effects that simulate room acoustics and spatial reflections.

- [Convolution Reverb](/v2/reference/audio-modules/effects/master/convolution): Zero-latency convolution reverb with adjustable dry/wet levels, predelay, damping, and high-cut filtering for shaping impulse responses.
- [Simple Reverb](/v2/reference/audio-modules/effects/master/simplereverb): Algorithmic reverb based on Freeverb with controls for room size, damping, and stereo width.

---

### Routing

Modules that forward, distribute, or proxy signals or events across the module tree. Contains sound generators, MIDI processors, effects, and modulators.

- [MIDI CC to Note Generator](/v2/reference/audio-modules/midi-processors/cc2note): Turns a selected MIDI CC into a note trigger, useful for controller-driven drum or round-robin triggering.
- [CC Swapper](/v2/reference/audio-modules/midi-processors/ccswapper): Swaps two MIDI CC numbers to remap controller data without changing the source device or automation.
- [MIDI Channel Filter](/v2/reference/audio-modules/midi-processors/channelfilter): Filters incoming MIDI by channel, with optional MPE start and end channel ranges for MPE setups.
- [MIDI Channel Setter](/v2/reference/audio-modules/midi-processors/channelsetter): Rewrites the MIDI channel for all incoming messages, useful for routing or consolidating controllers.
- [EventData Envelope](/v2/reference/audio-modules/modulators/envelope/eventdataenvelope): An envelope modulator for time-varying event data slots, with smoothing for continuous modulation changes.
- [Event Data Modulator](/v2/reference/audio-modules/modulators/voice-start/eventdatamodulator): Creates a modulation value based on event data written through the global routing manager, allowing external control data to modulate voices.
- [Global Envelope Modulator](/v2/reference/audio-modules/modulators/envelope/globalenvelopemodulator): Connects to a global EnvelopeModulator in a GlobalModulatorContainer, allowing envelope modulation to be shared across multiple targets.
- [Global Modulator Container](/v2/reference/audio-modules/sound-generators/globalmodulatorcontainer): A container that processes Modulator instances that can be used at different locations.
- [Global Static Time Variant Modulator](/v2/reference/audio-modules/modulators/voice-start/globalstatictimevariantmodulator): Captures the current value of a global TimeVariantModulator at voice start, creating a constant per-voice modulation based on the LFO/envelope state at note-on.
- [Global Time Variant Modulator](/v2/reference/audio-modules/modulators/time-variant/globaltimevariantmodulator): Shares a global TimeVariantModulator signal across multiple targets, allowing real-time continuous modulation from a single source.
- [Global Voice Start Modulator](/v2/reference/audio-modules/modulators/voice-start/globalvoicestartmodulator): Connects to a global VoiceStartModulator in a GlobalModulatorContainer, allowing voice-start modulation to be shared across multiple targets.
- [Macro Modulation Source](/v2/reference/audio-modules/sound-generators/macromodulationsource): A container that hosts modulator chains whose output drives the macro control system.
- [Macro Modulator](/v2/reference/audio-modules/modulators/time-variant/macromodulator): A modulator controlled by a macro controller slot, allowing real-time automation and MIDI learn functionality.
- [Matrix Modulator](/v2/reference/audio-modules/modulators/envelope/matrixmodulator): Combines multiple global modulators into a single modulation source with a base value and smoothed output.
- [MidiMuter](/v2/reference/audio-modules/midi-processors/midimuter): Mutes incoming note-on events while allowing other MIDI messages, with optional stuck-note protection.
- [Routing Matrix](/v2/reference/audio-modules/effects/master/routefx): Routing matrix for duplicating and distributing audio across channels, useful for building aux-style signal paths and complex channel layouts.
- [Send Container](/v2/reference/audio-modules/sound-generators/sendcontainer): A signal chain tool that receives the signal from a Send FX and applies its own effect chain.
- [Send Effect](/v2/reference/audio-modules/effects/master/sendfx): Routes audio to a send container with adjustable gain, channel offset, and optional smoothing for consistent send automation.
- [Effect Slot](/v2/reference/audio-modules/effects/master/slotfx): A placeholder for another effect that can be swapped dynamically.

---

### Utility

Modules for analysis, placeholders, or structural purposes without audio processing.

- [Analyser](/v2/reference/audio-modules/effects/master/analyser): Provides audio visualization tools including goniometer, oscilloscope, and spectrum analyzer.
- [Empty](/v2/reference/audio-modules/effects/master/emptyfx): A placeholder effect that passes audio through unchanged, useful for routing or as a template.
- [MidiMetronome](/v2/reference/audio-modules/effects/master/midimetronome): A metronome that produces click sounds synchronized to a connected MIDI player's tempo.
- [Noise Grain Player](/v2/reference/audio-modules/effects/polyphonic/noisegrainplayer): A polyphonic granular noise player that blends an audio file with white noise at a configurable grain size.
- [Simple Gain](/v2/reference/audio-modules/effects/master/simplegain): Utility gain processor with optional delay, stereo width, and balance control, useful for level automation, simple timing offsets, and mid-side shaping.
- [Effect Slot](/v2/reference/audio-modules/effects/master/slotfx): A placeholder for another effect that can be swapped dynamically.

---

### Mixing

Effects that control volume, stereo width, or stereo balance. Contains effects and MIDI processors.

- [Parametriq EQ](/v2/reference/audio-modules/effects/master/curveeq): A parametric equalizer with unlimited filter bands and an FFT spectrum display for visual feedback.
- [Dynamics](/v2/reference/audio-modules/effects/master/dynamics): A dynamics processor combining gate, compressor, and limiter based on chunkware's SimpleCompressor algorithms.
- [MidiMuter](/v2/reference/audio-modules/midi-processors/midimuter): Mutes incoming note-on events while allowing other MIDI messages, with optional stuck-note protection.
- [Send Effect](/v2/reference/audio-modules/effects/master/sendfx): Routes audio to a send container with adjustable gain, channel offset, and optional smoothing for consistent send automation.
- [Simple Gain](/v2/reference/audio-modules/effects/master/simplegain): Utility gain processor with optional delay, stereo width, and balance control, useful for level automation, simple timing offsets, and mid-side shaping.
- [Stereo FX](/v2/reference/audio-modules/effects/polyphonic/stereofx): Polyphonic stereo panner with width control and modulatable pan position.
