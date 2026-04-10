---
title: Smoother
description: "A one-pole lowpass filter that smooths channel 0 of the input signal."
factoryPath: core.smoother
factory: core
polyphonic: true
tags: [core, smoothing, filter, utility]
cpuProfile:
  baseline: negligible
  polyphonic: true
  scalingFactors: []
seeAlso:
  - { id: "filters.one_pole", type: alternative, reason: "Full one-pole filter processing all channels" }
commonMistakes:
  - title: "Only channel 0 is smoothed"
    wrong: "Expecting the smoother to process all channels equally"
    right: "Only channel 0 is filtered. Other channels pass through unmodified. Use filters.one_pole if you need all channels smoothed."
    explanation: "The node applies its lowpass filter to channel 0 only. In a stereo signal, the right channel is untouched."
llmRef: |
  core.smoother

  One-pole lowpass filter applied to channel 0 only. Smooths rapid changes to reduce zipper noise or create gradual transitions. Resets to DefaultValue on voice start or note-on.

  Signal flow:
    channel 0 -> one-pole lowpass -> channel 0 (other channels pass through)

  CPU: negligible, polyphonic

  Parameters:
    SmoothingTime (0-2000 ms, default 100): Filter time constant
    DefaultValue (0-100%, default 0%): Initial output value on voice start/reset

  When to use:
    - Smoothing a control signal or modulation value on channel 0
    - Reducing zipper noise from stepped parameter changes
    - Use filters.one_pole instead when all channels need filtering

  Common mistakes:
    - Only channel 0 is processed; other channels are untouched

  See also:
    alternative filters.one_pole -- one-pole filter for all channels
---

The smoother applies a one-pole lowpass filter to channel 0 of the input signal, reducing rapid changes and creating smooth transitions. It is commonly used to smooth control signals or reduce zipper noise from stepped modulation values.

On voice start or MIDI note-on, the filter state resets to the DefaultValue, then tracks the input signal with the configured time constant. Only channel 0 is filtered; other channels pass through unmodified.

## Signal Path

::signal-path
---
glossary:
  parameters:
    SmoothingTime:
      desc: "Filter time constant controlling how quickly the output tracks the input"
      range: "0 - 2000 ms"
      default: "100"
    DefaultValue:
      desc: "Initial output value on voice start or reset"
      range: "0 - 100%"
      default: "0%"
  functions:
    onePoleFilter:
      desc: "Applies exponential smoothing to each sample, gradually approaching the input value"
---

```
// core.smoother - one-pole lowpass on channel 0
// audio in -> audio out (channel 0 filtered)

process(input) {
    input[ch0] = onePoleFilter(input[ch0], SmoothingTime)
    // other channels pass through unchanged
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Signal
    params:
      - { name: SmoothingTime, desc: "Filter time constant in milliseconds. Higher values produce slower, smoother transitions", range: "0 - 2000 ms", default: "100" }
      - { name: DefaultValue, desc: "Initial output value applied when a voice starts or the node is reset. The output begins at this value and then smoothly transitions to track the input", range: "0 - 100%", default: "0%" }
---
::

## Notes

The smoother processes channel 0 only. For a filter that operates on all channels, use [filters.one_pole]($SN.filters.one_pole$).

**See also:** $SN.filters.one_pole$ -- one-pole filter processing all channels
