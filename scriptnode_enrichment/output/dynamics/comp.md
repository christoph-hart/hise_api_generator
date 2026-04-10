---
title: Comp
description: "A downward compressor with peak detection, adjustable threshold, ratio, attack, and release."
factoryPath: dynamics.comp
factory: dynamics
polyphonic: false
tags: [dynamics, compressor, sidechain]
cpuProfile:
  baseline: low
  polyphonic: false
  scalingFactors: []
seeAlso:
  - { id: "dynamics.gate", type: alternative, reason: "Gate for attenuating below threshold instead of compressing above" }
  - { id: "dynamics.limiter", type: alternative, reason: "Limiter optimised for peak control" }
  - { id: "dynamics.updown_comp", type: alternative, reason: "Dual-threshold compressor with upward and downward compression" }
  - { id: "dynamics.envelope_follower", type: companion, reason: "Envelope tracking without gain reduction" }
  - { id: "jdsp.jcompressor", type: alternative, reason: "Alternative compressor node" }
commonMistakes:
  - title: "Sidechain mode needs extra channels"
    wrong: "Enabling Sidechain mode on a stereo signal and expecting it to use an external key signal"
    right: "Route four channels into the node: channels 1-2 for audio, channels 3-4 for the sidechain key signal."
    explanation: "Sidechain mode splits the incoming channels in half. For stereo processing with an external key signal, the container must provide four channels."
  - title: "Disabled and Original are identical"
    wrong: "Switching between Disabled and Original expecting different behaviour"
    right: "Use Disabled for self-keyed compression. Use Sidechain for external keying."
    explanation: "The Disabled and Original sidechain modes both use the input signal as the detection source. Only the Sidechain mode enables external keying."
llmRef: |
  dynamics.comp

  Downward compressor with peak detection. Reduces gain when the input exceeds the threshold, controlled by ratio, attack, and release. Outputs inverse gain reduction as a normalised modulation signal.

  Signal flow:
    audio in -> peak detect -> compress (threshold, ratio, attack, release) -> audio out
    compress -> modulation out (1.0 - gain reduction)

  CPU: low, monophonic

  Parameters:
    Dynamics:
      Threshhold: -100 - 0 dB (default 0). Level above which compression begins.
      Attack: 0 - 250 ms (default 50). How fast compression engages.
      Release: 0 - 250 ms (default 50). How fast compression releases.
      Ratio: 1 - 32 (default 1). Compression ratio (1:1 = no compression, 32:1 = hard limiting).
    Routing:
      Sidechain: Disabled / Original / Sidechain (default Disabled). Detection source.

  When to use:
    Standard downward compression for dynamic control. Use dynamics.gate for gating below threshold, dynamics.limiter for peak limiting, or dynamics.updown_comp for combined upward/downward compression.

  Common mistakes:
    Sidechain mode requires double the channel count (4 channels for stereo).
    Disabled and Original modes are identical.

  See also:
    [alternative] dynamics.gate - gate for attenuating below threshold
    [alternative] dynamics.limiter - limiter optimised for peak control
    [alternative] dynamics.updown_comp - dual-threshold compressor
    [companion] dynamics.envelope_follower - envelope tracking without gain reduction
    [alternative] jdsp.jcompressor - alternative compressor node
---

A downward compressor that reduces gain when the input signal exceeds the threshold. The amount of gain reduction depends on the ratio, while attack and release control how quickly compression engages and recovers. The node outputs inverse gain reduction as a normalised modulation signal, which can drive other parameters for visualisation or dynamics-linked processing.

The compressor supports external sidechain keying by routing extra channels into the node. It processes stereo or mono signals frame by frame with peak detection.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Threshhold:
      desc: "Level above which compression begins"
      range: "-100 - 0 dB"
      default: "0"
    Attack:
      desc: "How fast compression engages"
      range: "0 - 250 ms"
      default: "50"
    Release:
      desc: "How fast compression releases"
      range: "0 - 250 ms"
      default: "50"
    Ratio:
      desc: "Compression ratio (1:1 to 32:1)"
      range: "1 - 32"
      default: "1"
    Sidechain:
      desc: "Detection source selection"
      range: "Disabled / Original / Sidechain"
      default: "Disabled"
  functions:
    peakDetect:
      desc: "Measures the peak level of the input or sidechain signal"
    compress:
      desc: "Applies gain reduction based on threshold, ratio, and envelope timing"
---

```
// dynamics.comp - downward compressor
// audio in -> audio out + modulation out

process(input) {
    level = peakDetect(input, Sidechain)
    gain = compress(level, Threshhold, Ratio, Attack, Release)
    output = input * gain
    modulation = 1.0 - gainReduction  // 0..1, higher = less compression
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Dynamics
    params:
      - { name: Threshhold, desc: "Level above which compression begins.", range: "-100 - 0 dB", default: "0" }
      - { name: Attack, desc: "How quickly compression engages after the signal exceeds the threshold.", range: "0 - 250 ms", default: "50" }
      - { name: Release, desc: "How quickly compression releases after the signal drops below the threshold.", range: "0 - 250 ms", default: "50" }
      - { name: Ratio, desc: "Compression ratio. 1:1 applies no compression; 32:1 approaches hard limiting.", range: "1 - 32", default: "1" }
  - label: Routing
    params:
      - { name: Sidechain, desc: "Detection source. Disabled and Original both use the input signal. Sidechain uses extra channels as the key signal.", range: "Disabled / Original / Sidechain", default: "Disabled" }
---
::

## Notes

The modulation output sends the inverse of the gain reduction, normalised to 0..1. A value of 1.0 means no compression is occurring; lower values indicate more compression. This can be routed to other parameters for gain reduction metering or dynamics-linked effects.

When using Sidechain mode, the node expects double the normal channel count. For stereo compression with an external key signal, route four channels into the node: the first two carry audio, the second two carry the sidechain key signal.

The display buffer shows the gain reduction over time, using the same value as the modulation output.

**See also:** $SN.dynamics.gate$ -- gate for attenuating below threshold, $SN.dynamics.limiter$ -- limiter optimised for peak control, $SN.dynamics.updown_comp$ -- dual-threshold compressor with upward and downward compression, $SN.dynamics.envelope_follower$ -- envelope tracking without gain reduction
