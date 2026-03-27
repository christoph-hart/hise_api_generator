---
title: Global Envelope Modulator
moduleId: GlobalEnvelopeModulator
type: Modulator
subtype: EnvelopeModulator
tags: [routing]
builderPath: b.Modulators.GlobalEnvelopeModulator
screenshot: /images/v2/reference/audio-modules/globalenvelopemodulator.png
cpuProfile:
  baseline: low
  polyphonic: true
  scalingFactors: [table enabled]
seeAlso:
  - { id: GlobalModulatorContainer, type: source, reason: "Hosts the source envelope that this modulator reads from" }
  - { id: MatrixModulator, type: alternative, reason: "Combines multiple global modulators into one output with per-connection modes, rather than reading a single source" }
commonMistakes:
  - wrong: "Adding a Global Envelope without selecting a source in the dropdown"
    right: "Select a source envelope from the Connection dropdown"
    explanation: "When disconnected, the modulator outputs a constant 1.0 (gain mode) or 0.0 (pitch mode) and does not track any envelope."
  - wrong: "Expecting the Inverted toggle to invert the envelope signal"
    right: "The Inverted parameter has no effect"
    explanation: "The Inverted toggle is visible in the editor but has no effect on the output. Use a table with an inverted curve as a workaround."
customEquivalent:
  approach: scriptnode
  moduleType: Modulator
  complexity: low
  description: "A global cable receiving envelope values with optional table lookup node"
llmRef: |
  Global Envelope Modulator (EnvelopeModulator)

  Reads per-voice envelope values from a source envelope hosted in a Global Modulator Container. Acts as a lightweight proxy - the actual envelope shape is determined entirely by the source.

  Signal flow:
    Source envelope buffer (from container) -> optional table lookup (per-sample) -> modulation output
    Voice sync uses event IDs, not voice indices, so it works across different Sound Generators.

  CPU: low. Copies pre-computed buffer from source. Optional per-sample table lookup adds moderate cost.

  Parameters:
    Monophonic (Off/On, default dynamic) - affects voice management, not envelope shape
    Retrigger (Off/On, default On) - affects voice management, not envelope shape
    UseTable (Off/On, default Off) - enables lookup table for value transformation
    Inverted (Off/On, default Off) - vestigial, has no effect

  When to use:
    When the same envelope shape needs to modulate parameters across multiple Sound Generators. Place the source envelope in a Global Modulator Container, then add this consumer wherever needed.

  Common mistakes:
    No source selected - outputs constant 1.0.
    Inverted toggle has no effect.

  See also:
    source GlobalModulatorContainer - hosts the source envelope
    alternative MatrixModulator - combines multiple global sources
---

::category-tags
---
tags:
  - { name: routing, desc: "Modules that forward, distribute, or proxy signals or events across the module tree" }
---
::

![Global Envelope Modulator screenshot](/images/v2/reference/audio-modules/globalenvelopemodulator.png)

The Global Envelope Modulator reads per-voice envelope values from a source envelope hosted in a Global Modulator Container. It acts as a lightweight proxy - the actual envelope shape (attack, decay, sustain, release) is determined entirely by the source. Each voice in this modulator is synchronised to the corresponding voice in the source via event matching, so it works correctly even when the consumer and source belong to different Sound Generators with independent voice allocation.

An optional lookup table can reshape the envelope values per-sample before they reach the modulation output. This is useful for applying custom response curves to a shared envelope without modifying the original.

## Signal Path

::signal-path
---
glossary:
  parameters:
    UseTable:
      desc: "Enables the lookup table for value transformation"
      range: "Off / On"
      default: "Off"
  functions:
    tableLookup:
      desc: "Reads the response curve table at the envelope value position (0-1 input, 0-1 output)"
    copySourceBuffer:
      desc: "Copies the pre-computed envelope buffer from the source in the Global Modulator Container"
---

```
// Global Envelope Modulator - per-voice, envelope
// reads from source envelope in Global Modulator Container

onNoteOn() {
    // Match this voice to the source envelope via event ID
}

perVoiceBlock() {
    if not connected:
        output = 1.0  // pass-through
        return

    copySourceBuffer()

    if UseTable:
        for each sample:
            output[sample] = tableLookup(sourceValue[sample])
    else:
        output = sourceBuffer
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Value Processing
    params:
      - { name: UseTable, desc: "Enables a lookup table to transform the incoming envelope values. The table maps each sample value (0-1) to an output value (0-1) before the modulation output.", range: "Off / On", default: "Off" }
      - { name: Inverted, desc: "This parameter has no effect.", range: "Off / On", default: "Off" }
  - label: Voice Mode
    params:
      - { name: Monophonic, desc: "Enables monophonic mode. Affects how voices are managed locally but does not change the envelope shape, which is always determined by the source.", range: "Off / On", default: "(dynamic)" }
      - { name: Retrigger, desc: "Restarts the envelope proxy when a new note is triggered in monophonic mode. Does not affect the source envelope's behaviour.", range: "Off / On", default: "On" }
---
::

## Notes

The `Inverted` parameter is visible in the editor but has no effect on the modulation output. To invert the envelope, use a table with an inverted curve (draw a line from top-left to bottom-right).

Voice synchronisation between the container and this consumer uses event IDs rather than voice indices. This means the system works correctly even when the consumer's parent Sound Generator has a different voice count or allocation order than the container. For monophonic source envelopes, all consumer voices read from the same buffer.

When disconnected (no source selected), the modulator outputs a constant 1.0 in gain mode or 0.0 in pitch mode.

The Monophonic and Retrigger parameters affect the local voice management framework but do not influence the envelope shape, which is always determined by the source envelope in the container.

**See also:** $MODULES.GlobalModulatorContainer$ -- hosts the source envelope that this modulator reads from, $MODULES.MatrixModulator$ -- combines multiple global modulators into one output with per-connection modes