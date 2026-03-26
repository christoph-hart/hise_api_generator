---
title: Matrix Modulator
moduleId: MatrixModulator
type: Modulator
subtype: EnvelopeModulator
tags: [routing]
builderPath: b.Modulators.MatrixModulator
screenshot: /images/v2/reference/audio-modules/matrixmodulator.png
cpuProfile:
  baseline: medium
  polyphonic: true
  scalingFactors: [number of connections, smoothing active, output range skew]
seeAlso:
  - { id: GlobalModulatorContainer, type: source, reason: "Hosts the source modulators that this matrix reads from" }
  - { id: GlobalEnvelopeModulator, type: alternative, reason: "Reads a single envelope source. Matrix Modulator can combine multiple sources with per-connection modes." }
  - { id: GlobalTimeVariantModulator, type: alternative, reason: "Reads a single time-variant source. Matrix Modulator can combine multiple sources." }
commonMistakes:
  - wrong: "Expecting the Matrix Modulator to work without a Global Modulator Container in the module tree"
    right: "Add a Global Modulator Container with source modulators first"
    explanation: "The Matrix Modulator reads from modulators hosted in a Global Modulator Container. Without one, there are no sources to connect to and the modulator outputs only its base value."
  - wrong: "Mixing up Scale and Add connection modes"
    right: "Scale multiplies against the base value, Add offsets from it"
    explanation: "The combination formula is: output = (baseValue * scaleMod1 * scaleMod2 * ...) + addMod1 + addMod2 + ... Scale connections are applied first (multiplicative), then Add connections (additive)."
customEquivalent:
  approach: scriptnode
  moduleType: Modulator
  complexity: medium
  description: "Multiple global cables feeding into a multiplication/addition network with smoothed base value"
llmRef: |
  Matrix Modulator (EnvelopeModulator)

  Combines multiple global modulators from a Global Modulator Container into a single modulation output via a connection matrix. Each connection has a mode (Scale/Add/Bipolar), intensity, and optional auxiliary source.

  Signal flow:
    Base value (smoothed) -> multiply by all Scale connections -> add all Add connections -> optional output range skew -> modulation output

  Combination formula: output = (baseValue * scaleMod1 * ... * scaleModN) + addMod1 + ... + addModM

  CPU: medium, scaling with number of connections. Per-sample smoothing of base value plus per-sample processing per connection.

  Parameters:
    Monophonic (Off/On, default dynamic) - skips inner node reset in monophonic mode
    Retrigger (Off/On, default On) - restarts on new note in monophonic mode
    Value (0-100%, default dynamic) - base value before connections are applied
    SmoothingTime (0-2000 ms, default 50 ms) - smoothing time for base value transitions

  Connection modes:
    Scale - multiplicative (multiplies against base value)
    Add - additive (offsets from base value)
    Bipolar - additive with bipolar range display

  When to use:
    When you need to combine multiple global modulators into a single modulation output with individual per-connection modes and intensities. More flexible than single-source Global*Modulator consumers.

  UI: ModulationMatrixPanel and ModulationMatrixControlPanel FloatingTiles.

  Common mistakes:
    Requires a GlobalModulatorContainer with source modulators.
    Scale and Add modes have different combination order.

  See also:
    source GlobalModulatorContainer - hosts the source modulators
    alternative GlobalEnvelopeModulator, GlobalTimeVariantModulator - single-source consumers
---

::category-tags
---
tags:
  - { name: routing, desc: "Modules that forward, distribute, or proxy signals or events across the module tree" }
---
::

![Matrix Modulator screenshot](/images/v2/reference/audio-modules/matrixmodulator.png)

The Matrix Modulator combines multiple global modulators from a Global Modulator Container into a single modulation output. Unlike the single-source Global*Modulator consumers, this module provides a connection matrix where each connection has its own mode (Scale, Add, or Bipolar), intensity, and optional auxiliary source.

The base Value parameter sets the starting point. Scale connections multiply against it, then Add connections offset from the result. The smoothing parameter prevents clicks when the base value changes. When all connections are removed, the modulator automatically bypasses itself and outputs the base value directly.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Value:
      desc: "Base value before connections are applied"
      range: "0 - 100%"
      default: "(dynamic)"
    SmoothingTime:
      desc: "Smoothing time for base value transitions"
      range: "0 - 2000 ms"
      default: "50 ms"
  functions:
    smooth:
      desc: "Per-sample interpolation of the base value at the control rate"
    applyScaleMods:
      desc: "Multiplies the buffer by each Scale connection sequentially"
    applyAddMods:
      desc: "Adds each Add/Bipolar connection to the buffer sequentially"
---

```
// Matrix Modulator - per-voice, envelope
// combines multiple global modulators via connection matrix

onNoteOn() {
    // Reset smoothed base value, initialise all connections
}

perVoiceBlock() {
    // Fill buffer with smoothed base value
    for each sample:
        output[sample] = smooth(Value, SmoothingTime)

    // Apply Scale connections (multiplicative)
    applyScaleMods(output)

    // Apply Add connections (additive)
    applyAddMods(output)

    // Result: (baseValue * scale1 * scale2 ...) + add1 + add2 ...
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Base Value
    params:
      - { name: Value, desc: "The base modulation value before any connections are applied. Normalised to 0-1 via the input range. When all connections are removed, this is the only output.", range: "0 - 100%", default: "(dynamic)" }
      - { name: SmoothingTime, desc: "Time in milliseconds for the base value to reach a new target. Prevents clicks on value changes. At 0 ms the base value changes instantly.", range: "0 - 2000 ms", default: "50 ms" }
  - label: Voice Mode
    params:
      - { name: Monophonic, desc: "Enables monophonic mode. In monophonic mode, inner modulation nodes are not reset on new notes to maintain continuous signal.", range: "Off / On", default: "(dynamic)" }
      - { name: Retrigger, desc: "Restarts the modulator when a new note is triggered in monophonic mode.", range: "Off / On", default: "On" }
---
::

## Notes

The combination formula is: `output = (baseValue * scaleMod1 * scaleMod2 * ...) + addMod1 + addMod2 + ...`. Scale connections are always processed before Add connections, regardless of the order they appear in the connection table.

Each connection in the matrix has:
- A source modulator (selected from the container's chain)
- A mode: Scale (multiplicative), Add (additive), or Bipolar (additive with bipolar range display)
- An intensity slider (-1 to 1)
- An optional auxiliary source with its own intensity
- A per-connection inversion toggle

When all connections are removed, the modulator automatically bypasses itself and outputs the smoothed base value. This prevents unnecessary CPU usage when the matrix is not in use.

Connections are created via the matrix table editor, drag-and-drop from the container, or the right-click popup menu.

## See Also

::see-also
---
links:
  - { label: "Global Modulator Container", to: "/v2/reference/audio-modules/sound-generators/globalmodulatorcontainer", desc: "hosts the source modulators that this matrix reads from" }
  - { label: "Global Envelope Modulator", to: "/v2/reference/audio-modules/modulators/envelope/globalenvelopemodulator", desc: "reads a single envelope source (simpler, lower CPU)" }
  - { label: "Global Time Variant Modulator", to: "/v2/reference/audio-modules/modulators/time-variant/globaltimevariantmodulator", desc: "reads a single time-variant source (simpler, lower CPU)" }
---
::- **UI Component:** `ModulationMatrixPanel` - displays the connection matrix
- **UI Component:** `ModulationMatrixControlPanel` - provides drag buttons for creating connections
