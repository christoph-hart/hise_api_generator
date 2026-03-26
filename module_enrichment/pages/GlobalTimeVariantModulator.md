---
title: Global Time Variant Modulator
moduleId: GlobalTimeVariantModulator
type: Modulator
subtype: TimeVariantModulator
tags: [routing]
builderPath: b.Modulators.GlobalTimeVariantModulator
screenshot: /images/v2/reference/audio-modules/globaltimevariantmodulator.png
cpuProfile:
  baseline: low
  polyphonic: false
  scalingFactors: [table enabled]
seeAlso:
  - { id: GlobalModulatorContainer, type: source, reason: "Hosts the source time-variant modulator that this consumer reads from" }
  - { id: GlobalStaticTimeVariantModulator, type: disambiguation, reason: "Also reads from a TimeVariant source, but snapshots the value at note-on instead of continuously tracking" }
commonMistakes:
  - wrong: "Using the Inverted toggle with UseTable enabled and expecting inversion to work"
    right: "When UseTable is enabled, inversion has no effect. Use a table with an inverted curve instead."
    explanation: "Due to an internal issue, inversion is not applied when the table is active. Draw an inverted curve in the table as a workaround."
  - wrong: "Adding a Global Time Variant consumer without selecting a source"
    right: "Select a source from the Connection dropdown"
    explanation: "When disconnected, the modulator outputs a constant 1.0 and does not track any source."
customEquivalent:
  approach: scriptnode
  moduleType: Modulator
  complexity: low
  description: "A global cable receiving time-variant buffer with optional table lookup node"
llmRef: |
  Global Time Variant Modulator (TimeVariantModulator)

  Continuously reads a monophonic time-variant modulation buffer from a source TimeVariantModulator in a Global Modulator Container. Tracks the source in real time, block by block.

  Signal flow:
    Source buffer (from container, per-block) -> optional table lookup (per-sample) -> optional inversion -> modulation output

  CPU: low. Buffer copy per block. Optional per-sample table lookup adds moderate cost.

  Parameters:
    UseTable (Off/On, default Off) - enables lookup table for value transformation
    Inverted (Off/On, default Off) - inverts the output (1 - value). Note: does not work when UseTable is enabled.

  When to use:
    When the same continuous modulation source (LFO, etc.) needs to drive parameters across multiple targets in real time.

  Common mistakes:
    Inversion does not work when UseTable is enabled.
    No source selected - outputs constant 1.0.

  See also:
    source GlobalModulatorContainer - hosts the source modulator
    disambiguation GlobalStaticTimeVariantModulator - snapshots at note-on instead of continuous tracking
---

::category-tags
---
tags:
  - { name: routing, desc: "Modules that forward, distribute, or proxy signals or events across the module tree" }
---
::

![Global Time Variant Modulator screenshot](/images/v2/reference/audio-modules/globaltimevariantmodulator.png)

The Global Time Variant Modulator continuously reads a monophonic modulation buffer from a source time-variant modulator (such as an LFO) hosted in a Global Modulator Container. It tracks the source in real time, copying the full per-block buffer each audio cycle. This makes it suitable for any continuous modulation that needs to drive multiple targets simultaneously.

An optional lookup table can reshape the modulation values per-sample. The inversion toggle works in the non-table path but does not function when the table is active - use an inverted table curve as a workaround.

## Signal Path

::signal-path
---
glossary:
  parameters:
    UseTable:
      desc: "Enables the lookup table for value transformation"
      range: "Off / On"
      default: "Off"
    Inverted:
      desc: "Inverts the modulation output (1 - value). Does not work when UseTable is enabled."
      range: "Off / On"
      default: "Off"
  functions:
    tableLookup:
      desc: "Reads the response curve table at the source value position (0-1 input, 0-1 output), applied per-sample"
    copySourceBuffer:
      desc: "Copies the pre-computed time-variant buffer from the source in the Global Modulator Container"
---

```
// Global Time Variant Modulator - monophonic, time-variant
// reads from source TimeVariantModulator in Global Modulator Container

perBlock() {
    if not connected:
        fill(output, 1.0)  // pass-through
        return

    if UseTable:
        for each sample:
            output[sample] = tableLookup(sourceBuffer[sample])
        // Note: Inverted has no effect in this path
    else:
        copySourceBuffer()
        if Inverted:
            for each sample:
                output[sample] = 1.0 - output[sample]
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Value Processing
    params:
      - { name: UseTable, desc: "Enables a lookup table to transform the incoming modulation values per-sample. The table maps each source value (0-1) to an output value (0-1).", range: "Off / On", default: "Off" }
      - { name: Inverted, desc: "Inverts the modulation output by computing 1 minus the value. Only works when UseTable is disabled. When UseTable is enabled, inversion has no effect.", range: "Off / On", default: "Off" }
---
::

## Notes

The `Inverted` parameter only works when `UseTable` is disabled. When the table is active, inversion is not applied. To achieve inversion with a table, draw the table curve inverted (from top-left to bottom-right).

When disconnected (no source selected), the modulator fills its output buffer with 1.0 (pass-through in gain mode).

This modulator is monophonic - it reads from a single shared source buffer. All voices in the parent Sound Generator receive the same modulation values. For per-voice variation from a time-variant source, use the Global Static Time Variant Modulator instead, which snapshots the value at note-on.

## See Also

::see-also
---
links:
  - { label: "Global Modulator Container", to: "/v2/reference/audio-modules/sound-generators/globalmodulatorcontainer", desc: "hosts the source time-variant modulator" }
  - { label: "Global Static Time Variant Modulator", to: "/v2/reference/audio-modules/modulators/voice-start/globalstatictimevariantmodulator", desc: "also reads from a time-variant source, but snapshots the value at note-on for per-voice variation" }
---
::