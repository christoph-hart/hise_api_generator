---
title: Ladder
description: "A simple 4-pole (24 dB/octave) ladder lowpass filter."
factoryPath: filters.ladder
factory: filters
screenshot: /images/v2/reference/scriptnodes/filters/ladder.png
polyphonic: true
tags: [filters, ladder, lowpass, resonance]
cpuProfile:
  baseline: negligible
  polyphonic: true
  scalingFactors: []
seeAlso:
  - { id: "filters.moog", type: disambiguation, reason: "Moog-style ladder with more analog character" }
  - { id: "filters.svf", type: alternative, reason: "SVF with multiple filter types" }
commonMistakes: []
llmRef: |
  filters.ladder

  Simple 4-pole (24 dB/oct) ladder lowpass filter. Lightweight alternative to filters.moog with a cleaner character.

  Signal flow:
    audio in -> 4 cascaded one-pole stages with feedback -> audio out

  CPU: negligible, polyphonic

  Parameters:
    Frequency: 20 - 20000 Hz (default 1000). Cutoff frequency.
    Q: 0.3 - 9.9 (default 1.0). Resonance.
    Gain: -18 - 18 dB (default 0). Ignored.
    Smoothing: 0 - 1 s (default 0.01). Parameter interpolation time.
    Mode: LP24 only (default LP24).
    Enabled: Off / On (default On). Hard bypass.

  When to use:
    Lightweight 24 dB/oct lowpass when CPU matters and analog character is not needed. For warmer sound, use filters.moog instead.

  See also:
    [disambiguation] filters.moog - Moog-style ladder with more character
    [alternative] filters.svf - multimode SVF
---

A simple 4-pole (24 dB/octave) ladder lowpass filter. This is a lightweight alternative to [filters.moog]($SN.filters.moog$) - it uses four cascaded one-pole stages with feedback but without the analog-modelling constants, resulting in a cleaner sound and the lowest CPU cost of any multi-pole filter.

![Ladder screenshot](/images/v2/reference/scriptnodes/filters/ladder.png)

Only one mode is available (LP24). The Q parameter controls resonance feedback.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Frequency:
      desc: "Cutoff frequency"
      range: "20 - 20000 Hz"
      default: "1000"
    Q:
      desc: "Resonance feedback"
      range: "0.3 - 9.9"
      default: "1.0"
---

```
// filters.ladder - simple 4-pole ladder lowpass
// audio in -> audio out

process(input) {
    signal = input - state4 * resonance(Q)    // feedback

    state1 = (signal - state1) * cutoff + state1    // stage 1
    state2 = (state1 - state2) * cutoff + state2    // stage 2
    state3 = (state2 - state3) * cutoff + state3    // stage 3
    state4 = (state3 - state4) * cutoff + state4    // stage 4

    output = 2.0 * state4
}
```

::

## Frequency Response

::filter-response
---
dataUrl: /data/filter-curves.json
defaultResponse: magnitude
defaults:
  - ladder.LP24.Q05.F1000
  - ladder.LP24.Q10.F1000
  - ladder.LP24.Q50.F1000
---
::

## Parameters

::parameter-table
---
groups:
  - label: Signal
    params:
      - { name: Frequency, desc: "Cutoff frequency of the lowpass filter.", range: "20 - 20000 Hz", default: "1000" }
      - { name: Q, desc: "Resonance. Controls the feedback from the fourth stage back to the input.", range: "0.3 - 9.9", default: "1.0" }
      - { name: Gain, desc: "Not used. Present for interface consistency.", range: "-18 - 18 dB", default: "0.0" }
  - label: Configuration
    params:
      - { name: Mode, desc: "Fixed to LP24. Only one mode is available.", range: "LP24", default: "LP24" }
      - { name: Smoothing, desc: "Interpolation time for parameter changes.", range: "0.0 - 1.0 s", default: "0.01" }
      - { name: Enabled, desc: "Hard bypass.", range: "Off / On", default: "On" }
---
::

**See also:** $SN.filters.moog$ -- Moog-style ladder with more analog character, $SN.filters.svf$ -- multimode SVF with LP/HP/BP/Notch/Allpass
