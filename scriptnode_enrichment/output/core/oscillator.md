---
title: Oscillator
description: "A polyphonic tone generator with five waveform modes that adds its output to the existing signal."
factoryPath: core.oscillator
factory: core
polyphonic: true
tags: [core, oscillator, synthesis, waveform]
cpuProfile:
  baseline: low
  polyphonic: true
  scalingFactors:
    - parameter: Mode
      impact: negligible
      note: "Noise mode avoids table lookup but uses random number generation"
seeAlso:
  - { id: "core.phasor", type: alternative, reason: "Naive ramp output for waveshaping pipelines" }
  - { id: "core.fm", type: companion, reason: "FM operator that reads its modulator from the signal input" }
commonMistakes:
  - title: "Oscillator adds to existing signal"
    wrong: "Expecting the oscillator to replace the signal when placed in a chain"
    right: "The oscillator adds its output to whatever signal is already present. Use math.clear before it if you need a clean output."
    explanation: "The output is additive (input + waveform), so stacking multiple oscillators in the same chain sums their outputs. If the input already contains audio, it will be mixed in."
  - title: "Gate is not controlled by MIDI"
    wrong: "Assuming MIDI note-on and note-off toggle the Gate parameter automatically"
    right: "MIDI note-on sets the frequency but does not change Gate. Connect an envelope or MIDI gate source to the Gate parameter explicitly."
    explanation: "The node responds to MIDI note-on for pitch only. Gate defaults to 1 (always on) and must be controlled separately for note-on/note-off behaviour."
llmRef: |
  core.oscillator

  Polyphonic tone generator with five waveform modes (Sine, Saw, Triangle, Square, Noise). Adds its output to the existing audio signal. Responds to MIDI note-on for pitch tracking.

  Signal flow:
    [parameters] -> waveform generator -> output += waveform * Gain

  CPU: low, polyphonic

  Parameters:
    Mode (0-4, default 0/Sine): Selects waveform - Sine, Saw, Triangle, Square, Noise
    Frequency (20-20000 Hz, default 220): Base frequency, overridden by MIDI note-on
    Freq Ratio (1-16, default 1): Integer pitch multiplier applied to Frequency
    Gate (Off/On, default On): Enables output; rising edge resets phase
    Phase (0-100%, default 0%): Waveform phase offset
    Gain (0.0-1.0, default 1.0): Output amplitude

  When to use:
    - Primary tone generator for synthesiser patches
    - Stacking multiple oscillators for layered sounds
    - Use core.phasor instead when you need a raw ramp for waveshaping

  Common mistakes:
    - Output is additive, not replacing - use math.clear before if needed
    - MIDI controls pitch only, not Gate

  See also:
    alternative core.phasor -- naive ramp for waveshaping
    companion core.fm -- FM operator using signal input as modulator
---

The oscillator generates one of five waveform shapes and adds it to the audio signal passing through the node. In a polyphonic context, each voice maintains its own phase accumulator, and MIDI note-on messages set the oscillator frequency to match the incoming pitch.

The available waveforms are Sine, Saw, Triangle, Square, and Noise. At high frequencies, a Nyquist attenuation filter reduces the output amplitude to limit aliasing. The waveforms are naive (not band-limited), so for clean audible output at high pitches the Sine mode is the safest choice. For sub-audio modulation or waveshaping pipelines where aliasing is not a concern, [core.phasor]($SN.core.phasor$) provides a simpler ramp output.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Mode:
      desc: "Selects the waveform shape"
      range: "Sine / Saw / Triangle / Square / Noise"
      default: "Sine"
    Frequency:
      desc: "Base frequency in Hz (overridden by MIDI note-on)"
      range: "20 - 20000 Hz"
      default: "220"
    Freq Ratio:
      desc: "Integer multiplier applied to the base frequency"
      range: "1 - 16"
      default: "1"
    Gate:
      desc: "Enables or disables output; rising edge resets phase"
      range: "Off / On"
      default: "On"
    Phase:
      desc: "Phase offset for the waveform start position"
      range: "0 - 100%"
      default: "0%"
    Gain:
      desc: "Output amplitude before Nyquist attenuation"
      range: "0.0 - 1.0"
      default: "1.0"
  functions:
    generateWaveform:
      desc: "Produces a single sample from the selected waveform at the current phase position"
    nyquistAttenuation:
      desc: "Reduces amplitude at high frequencies to limit aliasing"
---

```
// core.oscillator - additive tone generator
// audio in -> audio out (input + waveform)

process(input) {
    if (!Gate) return input

    sample = generateWaveform(Mode, Phase)
    sample *= Gain * nyquistAttenuation(Frequency * Freq Ratio)
    output = input + sample
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Waveform
    params:
      - { name: Mode, desc: "Selects the waveform shape: Sine, Saw, Triangle, Square, or Noise", range: "Sine / Saw / Triangle / Square / Noise", default: "Sine" }
      - { name: Frequency, desc: "Base oscillator frequency. Overridden by MIDI note-on in a polyphonic context", range: "20 - 20000 Hz", default: "220" }
      - { name: "Freq Ratio", desc: "Integer multiplier applied to the base frequency for harmonic tuning", range: "1 - 16", default: "1" }
  - label: Control
    params:
      - { name: Gate, desc: "Enables or disables output. A rising edge resets the phase to zero", range: "Off / On", default: "On" }
      - { name: Phase, desc: "Phase offset for the waveform start position", range: "0 - 100%", default: "0%" }
      - { name: Gain, desc: "Output amplitude multiplier applied before Nyquist attenuation", range: "0.0 - 1.0", default: "1.0" }
---
::

## Notes

The oscillator output is additive: it sums with whatever signal is already in the buffer. This means you can stack multiple oscillators in a single chain to build layered tones. If you need a clean oscillator output without any existing signal, place a [math.clear]($SN.math.clear$) node before the oscillator.

MIDI note-on messages set the frequency but do not control the Gate parameter. To implement proper note-on/note-off behaviour, connect an envelope or gate signal to the Gate parameter.

**See also:** $SN.core.phasor$ -- naive ramp output for waveshaping pipelines, $SN.core.fm$ -- FM operator using signal input as modulator
