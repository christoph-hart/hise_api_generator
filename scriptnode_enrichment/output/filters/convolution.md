---
title: Convolution
description: "A partitioned FFT convolution reverb that convolves the input signal with an impulse response loaded from an AudioFile slot."
factoryPath: filters.convolution
factory: filters
screenshot: /images/v2/reference/scriptnodes/filters/convolution.png
polyphonic: false
tags: [filters, convolution, reverb, impulse-response, ir, fft]
cpuProfile:
  baseline: high
  polyphonic: false
  scalingFactors:
    - { parameter: "IR length", impact: "linear", note: "Longer impulse responses increase FFT partition count and processing time" }
seeAlso:
  - { id: "fx.reverb", type: alternative, reason: "Algorithmic reverb with lower CPU cost" }
commonMistakes:
  - title: "Always monophonic, not per-voice"
    wrong: "Placing filters.convolution inside a polyphonic voice chain expecting per-voice reverb"
    right: "Place convolution on a monophonic bus (after voice summing). It is always monophonic."
    explanation: "Convolution is inherently expensive and stateful. The node processes only the summed signal regardless of where it is placed. For per-voice spatial effects, use simpler filters or delays instead."
  - title: "Damping and HiCut trigger IR reload"
    wrong: "Modulating Damping or HiCut in real time expecting smooth changes"
    right: "Damping and HiCut are applied during impulse response loading, not in real time. Changes trigger a reload."
    explanation: "These parameters pre-process the impulse response. Changing them causes the IR to be reloaded with crossfading, which is not suited for continuous modulation."
llmRef: |
  filters.convolution

  Partitioned FFT convolution reverb with impulse response loading from an AudioFile slot. Mixes wet signal at approximately 50% with the dry input. Monophonic only.

  Signal flow:
    audio in -> FFT convolution with IR -> predelay -> wet/dry mix -> audio out

  CPU: high, monophonic. Scales linearly with IR length. Multithread offloads tail to background thread.

  Parameters:
    Gate: Off / On (default On). Enables/disables processing with click-free ramp.
    Predelay: 0 - 1000 ms (default 0). Delay applied to wet signal.
    Damping: -100 - 0 dB (default 0). Exponential decay applied to IR during loading.
    HiCut: 20 - 20000 Hz (default 20000). Frequency-dependent decay applied to IR during loading.
    Multithread: Off / On (default Off). Offloads tail convolution to background thread.

  When to use:
    Reverb and IR-based effects in scriptnode. Place on a bus, not per-voice. Use Gate to save CPU when convolution is not needed.

  Common mistakes:
    Not polyphonic - always processes summed output.
    Damping and HiCut are not real-time - they trigger IR reload.

  See also:
    [alternative] fx.reverb - algorithmic reverb with lower CPU
---

A partitioned FFT convolution reverb that convolves the input signal with an impulse response loaded from an AudioFile slot. The wet signal is mixed at approximately 50% with the dry input. This is the only filter node that is not polyphonic - it always processes the summed signal on a monophonic bus.

![Convolution screenshot](/images/v2/reference/scriptnodes/filters/convolution.png)

Damping and HiCut are pre-processing parameters applied to the impulse response during loading, not in real time. Changing them triggers a crossfaded IR reload. Use the Gate parameter to disable convolution entirely when it is not needed, saving CPU.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Gate:
      desc: "Enables or disables convolution processing"
      range: "Off / On"
      default: "On"
    Predelay:
      desc: "Delay applied to the wet signal"
      range: "0 - 1000 ms"
      default: "0"
    Damping:
      desc: "Exponential decay applied to the IR during loading"
      range: "-100 - 0 dB"
      default: "0"
    HiCut:
      desc: "Frequency-dependent decay applied to the IR during loading"
      range: "20 - 20000 Hz"
      default: "20000"
    Multithread:
      desc: "Offloads tail FFT to a background thread"
      range: "Off / On"
      default: "Off"
  functions:
    fftConvolve:
      desc: "Partitioned FFT convolution with the loaded impulse response"
---

```
// filters.convolution - FFT convolution reverb
// audio in -> audio out (wet/dry mix)

process(input) {
    if Gate == Off:
        output = input    // bypass, saves CPU
        return

    wet = fftConvolve(input, impulseResponse)

    if Predelay > 0:
        wet = delay(wet, Predelay)

    output = input * 0.5 + wet * 0.5    // fixed wet/dry mix
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Signal
    params:
      - { name: Gate, desc: "Enables or disables convolution processing. When off, only the dry signal passes through, saving CPU. Transitions use a click-free ramp.", range: "Off / On", default: "On" }
      - { name: Predelay, desc: "Delay applied to the wet (convolved) signal before mixing.", range: "0 - 1000 ms", default: "0" }
  - label: IR Processing
    params:
      - { name: Damping, desc: "Exponential decay applied to the impulse response during loading. Lower values shorten the reverb tail. 0 dB means no damping. Changes trigger an IR reload.", range: "-100 - 0 dB", default: "0" }
      - { name: HiCut, desc: "Frequency-dependent decay applied to the impulse response during loading. Simulates high-frequency absorption - lower values make the tail darker. 20000 Hz means no filtering. Changes trigger an IR reload.", range: "20 - 20000 Hz", default: "20000" }
  - label: Performance
    params:
      - { name: Multithread, desc: "When on, the tail portion of the convolution runs on a background thread, reducing audio thread load. Automatically disabled during offline rendering.", range: "Off / On", default: "Off" }
---
::

## Notes

The node does not support frame-based processing. It must be placed in a block-processing context (not inside a [container.frame2_block]($SN.container.frame2_block$)).

The wet/dry mix is fixed at approximately 50% and cannot be adjusted. To control the wet/dry balance, place the convolution node in a [container.split]($SN.container.split$) with a [control.xfader]($SN.control.xfader$) controlling the mix between the dry path and the convolution path.

The AudioFile slot accepts audio files directly. SampleMap and SFZ references are not supported.

**See also:** $SN.fx.reverb$ -- algorithmic reverb with lower CPU cost
