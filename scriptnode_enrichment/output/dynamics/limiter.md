---
title: Limiter
description: "A peak limiter with fast envelope detection for transparent peak control."
factoryPath: dynamics.limiter
factory: dynamics
polyphonic: false
tags: [dynamics, limiter, sidechain]
cpuProfile:
  baseline: low
  polyphonic: false
  scalingFactors: []
seeAlso:
  - { id: "dynamics.comp", type: alternative, reason: "General-purpose compressor with standard envelope" }
  - { id: "dynamics.gate", type: alternative, reason: "Gate for attenuating below threshold" }
commonMistakes:
  - title: "Sidechain mode needs extra channels"
    wrong: "Enabling Sidechain mode on a stereo signal and expecting it to use an external key signal"
    right: "Route four channels into the node: channels 1-2 for audio, channels 3-4 for the sidechain key signal."
    explanation: "Sidechain mode splits the incoming channels in half. For stereo processing with an external key signal, the container must provide four channels."
  - title: "Set a high ratio for brickwall limiting"
    wrong: "Using Ratio 1 and expecting the limiter to catch peaks"
    right: "Set Ratio to a high value (16 or above) for effective peak limiting."
    explanation: "Ratio 1:1 means no gain reduction. The limiter only becomes effective at higher ratios, with very high values approaching brickwall behaviour."
llmRef: |
  dynamics.limiter

  Peak limiter with fast envelope detection. Limits peaks above the threshold, controlled by ratio, attack, and release. Outputs inverse gain reduction as a normalised modulation signal.

  Signal flow:
    audio in -> peak detect -> limit (threshold, ratio, attack, release) -> audio out
    limit -> modulation out (1.0 - gain reduction)

  CPU: low, monophonic

  Parameters:
    Dynamics:
      Threshhold: -100 - 0 dB (default 0). Level above which limiting begins.
      Attack: 0 - 250 ms (default 50). How fast limiting engages.
      Release: 0 - 250 ms (default 50). How fast limiting releases.
      Ratio: 1 - 32 (default 1). Limiting ratio (high values approach brickwall).
    Routing:
      Sidechain: Disabled / Original / Sidechain (default Disabled). Detection source.

  When to use:
    Peak control and brickwall limiting. For general-purpose compression with a standard envelope, use dynamics.comp. For gating, use dynamics.gate.

  Common mistakes:
    Sidechain mode requires double the channel count (4 channels for stereo).
    Ratio 1:1 applies no limiting.

  See also:
    [alternative] dynamics.comp - general-purpose compressor
    [alternative] dynamics.gate - gate for attenuating below threshold
---

A peak limiter that reduces gain when the input exceeds the threshold. The limiter uses fast envelope detection optimised for transparent peak control, making it more suitable for catching transients than the general-purpose [dynamics.comp]($SN.dynamics.comp$). At high ratio values the limiter approaches brickwall behaviour.

The limiter supports external sidechain keying and outputs inverse gain reduction as a normalised modulation signal.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Threshhold:
      desc: "Level above which limiting begins"
      range: "-100 - 0 dB"
      default: "0"
    Attack:
      desc: "How fast limiting engages"
      range: "0 - 250 ms"
      default: "50"
    Release:
      desc: "How fast limiting releases"
      range: "0 - 250 ms"
      default: "50"
    Ratio:
      desc: "Limiting ratio (high values approach brickwall)"
      range: "1 - 32"
      default: "1"
    Sidechain:
      desc: "Detection source selection"
      range: "Disabled / Original / Sidechain"
      default: "Disabled"
  functions:
    peakDetect:
      desc: "Measures the peak level of the input or sidechain signal"
    limit:
      desc: "Applies gain reduction to peaks above threshold with fast envelope detection"
---

```
// dynamics.limiter - peak limiter
// audio in -> audio out + modulation out

process(input) {
    level = peakDetect(input, Sidechain)
    gain = limit(level, Threshhold, Ratio, Attack, Release)
    output = input * gain
    modulation = 1.0 - gainReduction  // 1.0 = no limiting, 0.0 = full limiting
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Dynamics
    params:
      - { name: Threshhold, desc: "Level above which limiting begins.", range: "-100 - 0 dB", default: "0" }
      - { name: Attack, desc: "How quickly limiting engages after the signal exceeds the threshold.", range: "0 - 250 ms", default: "50" }
      - { name: Release, desc: "How quickly limiting releases after the signal drops below the threshold.", range: "0 - 250 ms", default: "50" }
      - { name: Ratio, desc: "Limiting ratio. Higher values produce stronger peak control, approaching brickwall limiting.", range: "1 - 32", default: "1" }
  - label: Routing
    params:
      - { name: Sidechain, desc: "Detection source. Disabled and Original both use the input signal. Sidechain uses extra channels as the key signal.", range: "Disabled / Original / Sidechain", default: "Disabled" }
---
::

## Notes

The modulation output sends the inverse of the gain reduction, normalised to 0..1. A value of 1.0 means no limiting is occurring; lower values indicate more gain reduction.

For effective peak limiting, set the ratio to a high value (16 or above). At Ratio 1:1, no gain reduction is applied regardless of the threshold setting.

When using Sidechain mode, the node expects double the normal channel count. For stereo limiting with an external key signal, route four channels into the node.

**See also:** $SN.dynamics.comp$ -- general-purpose compressor with standard envelope, $SN.dynamics.gate$ -- gate for attenuating below threshold
