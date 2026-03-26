---
title: Convolution Reverb
moduleId: Convolution
type: Effect
subtype: MasterEffect
tags: [reverb]
builderPath: b.Effects.Convolution
screenshot: /images/v2/reference/audio-modules/convolution.png
cpuProfile:
  baseline: very_high
  polyphonic: false
  scalingFactors:
    - { parameter: "IR length", impact: high, note: "Longer impulse responses increase tail convolution work proportionally" }
    - { parameter: UseBackgroundThread, impact: medium, note: "Moves tail processing off the audio thread but does not reduce total CPU" }
    - { parameter: FFTType, impact: medium, note: "Platform-optimised FFT implementations (IPP, Accelerate) are measurably faster than the fallback" }
seeAlso:
  - { id: SimpleReverb, type: alternative, reason: "Lightweight algorithmic reverb with much lower CPU cost but no impulse response loading" }
  - { id: Convolution, type: scriptnode, reason: "The fx.convolution scriptnode node shares the same DSP engine with additional routing flexibility" }
commonMistakes:
  - wrong: "Adding a Convolution Reverb and expecting to hear dry signal"
    right: "Raise DryGain from -100 dB to 0 dB for a standard wet/dry blend"
    explanation: "The default DryGain is -100 dB (silent) and WetGain is 0 dB, so the output is 100% wet with no dry signal. This is unusual for a reverb - most users will want to raise DryGain."
  - wrong: "Adjusting Damping or HiCut and expecting real-time filtering of the wet output"
    right: "These parameters reshape the impulse response itself, which triggers a full IR reload"
    explanation: "Damping and HiCut are applied to the impulse response offline during preparation, not as real-time filters. Changing them causes a brief reload with a crossfade."
  - wrong: "Leaving UseBackgroundThread off with a long impulse response"
    right: "Enable UseBackgroundThread for long IRs to reduce audio thread load"
    explanation: "Without background threading, the entire convolution runs on the audio thread, which can cause dropouts with long impulse responses."
customEquivalent:
  approach: scriptnode
  moduleType: HardcodedFX
  complexity: simple
  description: "The fx.convolution scriptnode node wraps the same two-stage FFT convolution engine"
llmRef: |
  Convolution Reverb (MasterEffect)

  Zero-latency convolution reverb that convolves the input signal with a loaded impulse response. Uses a two-stage partitioned FFT architecture: a small head convolver for low latency and a larger tail convolver for the bulk of the IR, optionally on a background thread. Damping and HiCut shape the IR offline during preparation, not as real-time filters. A fixed 0.5x gain compensation is applied to the wet signal.

  Signal flow:
    IR preparation (offline): audio file -> resample to host rate -> apply Damping fadeout -> apply HiCut filtering -> initialise convolver engines
    Audio processing: audio in -> convolve (two-stage FFT) -> predelay -> wet gain -> 0.5x compensation -> sum with dry -> audio out

  CPU: very_high, monophonic (MasterEffect).
    Scaling: IR length (proportional), UseBackgroundThread (redistributes load), FFTType (platform FFT faster than fallback).

  Parameters:
    DryGain (-100 to 0 dB, default -100 dB) - dry output level. Default is silent.
    WetGain (-100 to 0 dB, default 0 dB) - wet output level. Subject to 0.5x gain compensation.
    Predelay (0-200 ms, default 0) - delay before reverb tail
    Damping (-100 to 0 dB, default 0 dB) - exponential fadeout applied to IR (offline, triggers reload)
    HiCut (20-20000 Hz, default 20000 Hz) - low-pass filtering applied to IR (offline, triggers reload)
    ProcessInput (On/Off, default On) - enables convolution with 60ms fade
    UseBackgroundThread (On/Off, default Off) - moves tail to background thread
    FFTType (0-4, default 0 BestAvailable) - FFT implementation: BestAvailable, IPP, AppleAccelerate, Ooura, FFTW3
    Latency (default 0) - this parameter has no effect
    ImpulseLength (default 1) - deprecated, has no effect

  When to use:
    High-quality reverb using real acoustic spaces or designed impulse responses. Best for static reverb characters. For lightweight algorithmic reverb, use Simple Reverb instead.

  Common mistakes:
    Default DryGain is -100 dB (silent) - raise to 0 dB for wet/dry blend.
    Damping and HiCut reshape the IR offline, triggering a reload on change.
    Enable UseBackgroundThread for long IRs to avoid audio thread overload.

  Custom equivalent:
    scriptnode HardcodedFX: fx.convolution node (same engine).

  See also:
    alternative SimpleReverb - lightweight algorithmic reverb, much lower CPU
    scriptnode fx.convolution - same DSP engine with scriptnode routing
---

::category-tags
---
tags:
  - { name: reverb, desc: "Effects that simulate room acoustics and spatial reflections" }
---
::

![Convolution Reverb screenshot](/images/v2/reference/audio-modules/convolution.png)

A zero-latency convolution reverb that convolves the input signal with a loaded impulse response (IR) audio file. It uses a two-stage partitioned FFT architecture to keep latency low while handling long impulse responses efficiently. The tail portion of the convolution can optionally run on a background thread to reduce audio thread load.

Unlike most reverb effects, the default mix is 100% wet: DryGain starts at -100 dB (silent) while WetGain starts at 0 dB. Raise DryGain to hear the original signal alongside the reverb. Damping and HiCut do not filter the wet output in real time - they reshape the impulse response itself during an offline preparation step, which triggers a brief crossfade when changed.

## Signal Path

::signal-path
---
glossary:
  parameters:
    DryGain:
      desc: "Dry output level in decibels, applied to the original input"
      range: "-100 - 0 dB"
      default: "-100 dB"
    WetGain:
      desc: "Wet output level in decibels, applied to the convolved signal"
      range: "-100 - 0 dB"
      default: "0 dB"
    Predelay:
      desc: "Delay before the reverb tail begins"
      range: "0 - 200 ms"
      default: "0 ms"
    Damping:
      desc: "Exponential fadeout applied to the IR (offline, triggers reload)"
      range: "-100 - 0 dB"
      default: "0 dB"
    HiCut:
      desc: "Low-pass cutoff applied to the IR (offline, triggers reload)"
      range: "20 - 20000 Hz"
      default: "20000 Hz"
    ProcessInput:
      desc: "Enables convolution processing with a 60ms fade transition"
      range: "Off / On"
      default: "On"
  functions:
    convolve:
      desc: "Two-stage partitioned FFT convolution: a small head block for low latency and a larger tail block for the remainder of the IR"
    applyDamping:
      desc: "Applies an exponential fadeout curve to the impulse response based on the Damping parameter"
    applyHiCut:
      desc: "Applies two cascaded one-pole low-pass filters with exponentially decreasing cutoff along the IR"
    predelay:
      desc: "Per-sample delay line that adds a time gap before the reverb tail"
---

```
// Convolution Reverb - monophonic, zero-latency
// stereo in -> stereo out

// IR Preparation (offline, on parameter change)
ir = loadAudioFile()
ir = resampleToHostRate(ir)
if Damping < 0 dB:
    ir = applyDamping(ir, Damping)
if HiCut < 20000 Hz:
    ir = applyHiCut(ir, HiCut)

// Audio processing (per block)
process(left, right) {
    wet = convolve(left, right, ir)

    if Predelay > 0:
        wet = predelay(wet, Predelay)

    // Apply gains (smoothed)
    dry = [left, right] * DryGain
    wet = wet * WetGain * 0.5    // fixed gain compensation

    output = dry + wet
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Mix Levels
    params:
      - { name: DryGain, desc: "Dry output level. The default is -100 dB, which is effectively silent. Raise this to hear the original signal alongside the reverb.", range: "-100 - 0 dB", default: "-100 dB" }
      - { name: WetGain, desc: "Wet output level for the convolved signal. A fixed 0.5x gain compensation is applied after this gain, so the effective maximum wet level is -6 dB.", range: "-100 - 0 dB", default: "0 dB" }
  - label: Impulse Response Shaping
    params:
      - { name: Damping, desc: "Applies an exponential fadeout to the impulse response. At 0 dB, the IR is unmodified. Lower values cause the IR tail to decay faster. This is applied offline during IR preparation and triggers a reload when changed.", range: "-100 - 0 dB", default: "0 dB" }
      - { name: HiCut, desc: "Low-pass cutoff frequency applied to the impulse response. At 20000 Hz, no filtering occurs. Lower values progressively remove high frequencies from the IR tail. Applied offline during IR preparation; triggers a reload when changed.", range: "20 - 20000 Hz", default: "20000 Hz" }
  - label: Timing
    params:
      - { name: Predelay, desc: "Adds a delay before the reverb tail. Applied in real time via a delay line on the convolved signal, before the wet gain stage.", range: "0 - 200 ms", default: "0 ms" }
  - label: Engine Configuration
    params:
      - { name: ProcessInput, desc: "Enables convolution processing. Toggling fades the wet signal in or out over 60ms to prevent clicks. When off, only the dry gain is applied.", range: "Off / On", default: "On" }
      - { name: UseBackgroundThread, desc: "Moves the tail convolution to a background thread, reducing audio thread load. The head convolution always runs on the audio thread. Automatically disabled during offline rendering.", range: "Off / On", default: "Off" }
      - { name: FFTType, desc: "Selects the FFT implementation for convolution. BestAvailable auto-selects the fastest option for the current platform. Changing this triggers an IR reload.", range: "BestAvailable, IPP, AppleAccelerate, Ooura, FFTW3", default: "BestAvailable" }
  - label: Vestigial
    params:
      - { name: Latency, desc: "This parameter has no effect. It is stored for serialisation but does not influence the convolution engine.", range: "0.0 - 1.0", default: "0" }
      - { name: ImpulseLength, desc: "Deprecated. This parameter has no effect. Use the sample area of the impulse response display to adjust the active range instead.", range: "0.0 - 1.0", default: "1" }
---
::

## Notes

The default mix is 100% wet (DryGain = -100 dB, WetGain = 0 dB). This differs from most reverb effects and means a newly added Convolution Reverb outputs only the convolved signal. Raise DryGain to 0 dB for a standard wet/dry blend.

A fixed 0.5x gain compensation is applied to the wet signal after the wet gain stage. At WetGain = 0 dB, the effective wet level is -6 dB. This compensates for the tendency of convolution to increase overall signal level.

Damping and HiCut are not real-time filters on the wet output. They modify the impulse response itself during an offline preparation step. Changing either parameter triggers a full IR reload with a ~20ms crossfade between the old and new convolver engines to prevent clicks.

The convolution engine uses a two-stage partitioned FFT architecture. The head convolver processes the first portion of the IR at the audio block size for zero-latency output. The tail convolver handles the remainder using a larger FFT size (up to 8192 samples). When UseBackgroundThread is enabled, the tail convolution runs on a dedicated background thread, freeing the audio thread for other processing.

When a new impulse response is loaded or the IR is modified, the module crossfades between the old and new convolver engines over approximately 20ms using a squared fade curve.

The reverb tail is cleared when voices are killed, preventing lingering reverb from previous notes.

## See Also

::see-also
---
links:
  - { label: "Simple Reverb", to: "/v2/reference/audio-modules/effects/master/simplereverb", desc: "Lightweight algorithmic reverb with much lower CPU cost but no impulse response loading" }
  - { label: "fx.convolution", to: "/v2/reference/audio-modules/effects/master/convolution", desc: "The scriptnode node shares the same two-stage FFT convolution engine with additional routing flexibility" }
---
::
