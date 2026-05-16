---
title: Gate
description: "A noise gate that attenuates signals falling below the threshold."
factoryPath: dynamics.gate
factory: dynamics
polyphonic: false
tags: [dynamics, gate, sidechain]
cpuProfile:
  baseline: low
  polyphonic: false
  scalingFactors: []
seeAlso:
  - { id: "dynamics.comp", type: alternative, reason: "Compressor for reducing gain above threshold" }
  - { id: "dynamics.limiter", type: alternative, reason: "Limiter for peak control" }
  - { id: "dynamics.envelope_follower", type: companion, reason: "Envelope tracking without gain reduction" }
  - { id: "Dynamics", type: module, reason: "Module-tree dynamics processor that combines compressor, gate, and limiter" }
commonMistakes:
  - title: "Sidechain mode needs extra channels"
    wrong: "Enabling Sidechain mode on a stereo signal and expecting it to use an external key signal"
    right: "Route four channels into the node: channels 1-2 for audio, channels 3-4 for the sidechain key signal."
    explanation: "Sidechain mode splits the incoming channels in half. For stereo processing with an external key signal, the container must provide four channels."
llmRef: |
  dynamics.gate

  Noise gate with peak detection. Attenuates signals below the threshold based on the ratio. Outputs gain reduction amount as a normalised modulation signal.

  Signal flow:
    audio in -> peak detect -> gate (threshold, ratio, attack, release) -> audio out
    gate -> modulation out (gain reduction amount: 0.0 = open, 1.0 = closed)

  CPU: low, monophonic

  Parameters:
    Dynamics:
      Threshhold: -100 - 0 dB (default 0). Level below which gating begins.
      Attack: 0 - 250 ms (default 50). How fast the gate opens.
      Release: 0 - 250 ms (default 50). How fast the gate closes.
      Ratio: 1 - 32 (default 1). Gating depth (1 = no gating, 32 = aggressive).
    Routing:
      Sidechain: Disabled / Original / Sidechain (default Disabled). Detection source.

  When to use:
    Attenuating noise or bleed below a threshold. Use dynamics.comp for downward compression above threshold, or dynamics.envelope_follower for amplitude tracking without gain changes.

  Common mistakes:
    Sidechain mode requires double the channel count (4 channels for stereo).

  Depth control:
    Invert the modulation connection range when you need an open-gate control signal (1.0 = open).

  See also:
    [alternative] dynamics.comp - compressor for gain reduction above threshold
    [alternative] dynamics.limiter - limiter for peak control
    [companion] dynamics.envelope_follower - envelope tracking without gain reduction
    [module] Dynamics - module-tree dynamics processor that combines compressor, gate, and limiter
forumReferences:
  - { tid: 12246, summary: "Gate depth control using core.pma to scale modulation output" }
---

A noise gate that attenuates signals falling below the threshold. The ratio controls the depth of attenuation: low ratios produce gentle expansion, while high ratios approach hard gating. Attack controls how quickly the gate opens when the signal rises above the threshold, and release controls how quickly it closes.

The gate supports external sidechain keying and outputs the gain reduction amount as a normalised modulation signal. This output is high while the gate is closed and low while it is open, so invert the modulation connection before using it to open another parameter.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Threshhold:
      desc: "Level below which gating begins"
      range: "-100 - 0 dB"
      default: "0"
    Attack:
      desc: "How fast the gate opens"
      range: "0 - 250 ms"
      default: "50"
    Release:
      desc: "How fast the gate closes"
      range: "0 - 250 ms"
      default: "50"
    Ratio:
      desc: "Gating depth (1 = no gating, 32 = aggressive)"
      range: "1 - 32"
      default: "1"
    Sidechain:
      desc: "Detection source selection"
      range: "Disabled / Original / Sidechain"
      default: "Disabled"
  functions:
    peakDetect:
      desc: "Measures the peak level of the input or sidechain signal"
    gate:
      desc: "Attenuates the signal when below threshold based on ratio and envelope timing"
---

```
// dynamics.gate - noise gate
// audio in -> audio out + modulation out

process(input) {
    level = peakDetect(input, Sidechain)
    gain = gate(level, Threshhold, Ratio, Attack, Release)
    output = input * gain
    modulation = gainReductionAmount  // 0.0 = open, 1.0 = closed
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Dynamics
    params:
      - { name: Threshhold, desc: "Level below which gating begins.", range: "-100 - 0 dB", default: "0" }
      - { name: Attack, desc: "How quickly the gate opens when the signal rises above the threshold.", range: "0 - 250 ms", default: "50" }
      - { name: Release, desc: "How quickly the gate closes after the signal drops below the threshold.", range: "0 - 250 ms", default: "50" }
      - { name: Ratio, desc: "Gating depth. 1 applies no gating; higher values attenuate more aggressively below the threshold.", range: "1 - 32", default: "1" }
  - label: Routing
    params:
      - { name: Sidechain, desc: "Detection source. Disabled and Original both use the input signal. Sidechain uses extra channels as the key signal.", range: "Disabled / Original / Sidechain", default: "Disabled" }
---
::

### Modulation Output

The modulation output sends the gain reduction amount, normalised to 0..1. A value near 1.0 means the gate is strongly reducing gain; a value near 0.0 means it is open. If you need a control signal that opens another parameter when the gate opens, invert the modulation connection by reversing the target range.

### Adjustable Gate Depth

By default the gate fully attenuates the signal when closed. To drive another target from gate-open activity, connect the gate modulation output to the target with an inverted target range. For example, a target range of `1..0` turns gain-reduction amount into open-gate activity: closed gate maps to 0, open gate maps to 1. For more detailed depth shaping, use [control.pma]($SN.control.pma$) to scale or offset the normalised gain-reduction signal before it reaches the target.

**See also:** $SN.dynamics.comp$ -- compressor for reducing gain above threshold, $SN.dynamics.limiter$ -- limiter for peak control, $SN.dynamics.envelope_follower$ -- envelope tracking without gain reduction, $MODULES.Dynamics$ -- module-tree dynamics processor that combines compressor, gate, and limiter
