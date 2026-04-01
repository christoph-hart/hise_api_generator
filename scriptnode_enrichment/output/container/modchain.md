---
title: Modulation Chain
description: "A serial container that processes children at control rate without affecting the parent audio signal."
factoryPath: container.modchain
factory: container
polyphonic: false
tags: [container, serial, modulation, control-rate]
cpuProfile:
  baseline: low
  polyphonic: false
  scalingFactors:
    - { parameter: "HISE_EVENT_RASTER", impact: "divisor", note: "Instrument plugins process at 1/8 rate; effect plugins at full rate" }
seeAlso:
  - { id: "container.chain", type: disambiguation, reason: "Audio-rate serial chain that modifies the signal" }
commonMistakes:
  - title: "Expecting modchain to modify audio"
    wrong: "Placing audio effect nodes inside a modchain and expecting the parent signal to change"
    right: "Use a regular container.chain for audio processing. Place modulation source nodes (core.peak, envelopes) inside modchain."
    explanation: "Modchain does not modify the parent audio signal. It processes a separate internal control buffer at reduced rate. Nodes inside it should generate modulation output via cables, not process audio."
llmRef: |
  container.modchain

  A serial container that processes children at control rate on an internal mono buffer without affecting the parent audio signal. Used to build modulation sources.

  Signal flow:
    parent audio -> [passthrough, unmodified] -> parent output
    internal: mono control buffer (zeroed) -> children process at reduced rate

  CPU: low, monophonic
    Instrument plugins: children run at 1/8 sample rate (HISE_EVENT_RASTER = 8).
    Effect plugins: children run at full sample rate (HISE_EVENT_RASTER = 1).

  Parameters:
    None

  When to use:
    Building modulation sources from DSP nodes. Typically contains oscillators, math nodes, and a core.peak node at the end to output the modulation signal via a cable.

  Common mistakes:
    Modchain does not modify parent audio. Use container.chain for audio processing.

  See also:
    [disambiguation] container.chain -- audio-rate serial chain that modifies the signal
---

The modulation chain processes its children on a separate internal mono buffer at a reduced sample rate, without affecting the parent audio signal. This is the standard way to build modulation sources from DSP nodes in scriptnode.

In instrument plugin contexts, children run at 1/8 of the original sample rate and block size (controlled by the `HISE_EVENT_RASTER` preprocessor, defaulting to 8). This significantly reduces CPU cost for modulation signals that do not require audio-rate precision. In effect plugin contexts, `HISE_EVENT_RASTER` is 1, so children run at full rate - only the mono channel restriction applies.

A typical modchain contains oscillator or math nodes to shape a control signal, with a [core.peak]($SN.core.peak$) node as the last child to output the result as a modulation signal via a cable. For a consistent modulation update rate independent of the host buffer size, wrap both the modchain and its modulation targets inside a fixed block size container.

## Signal Path

::signal-path
---
glossary:
  functions:
    control-rate dispatch:
      desc: "Processes children on an internal mono buffer at reduced sample rate"
---

```
// container.modchain - control-rate modulation chain
// parent audio passes through unmodified

dispatch(parentAudio) {
    // parent audio is not touched
    controlBuffer = zeroed mono buffer
    control-rate dispatch: children.process(controlBuffer)
    // modulation output sent via cables from child nodes
}
```

::

## Notes

- The modchain itself is not a modulation source. Nodes inside it (such as [core.peak]($SN.core.peak$)) produce the actual modulation output.
- When nested inside a frame-based container, the control-rate downsampling is disabled and children run at full audio rate.
- Modchain should not be nested inside a resampled container.

**See also:** $SN.container.chain$ -- audio-rate serial chain that modifies the signal
