# control.pack3_writer - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/pack3_writer.md`
- Reference: `scriptnode_enrichment/output/control/pack3_writer.md`

## Naming

- Module ID: `ThreePartialAdditiveMixer`
- Network ID: `three_partial_additive_mixer`

## Graph Plan

```text
three_partial_additive_mixer
  MidiContext            container.midichain
    PartialWriter        control.pack3_writer
    HarmonicPitch        control.clone_cable
    PartialLevels        control.clone_pack
    PartialBank          container.clone
      PartialVoice       container.chain
        SinePartial      core.oscillator
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Duplicate one oscillator chain to three clones and initialize external SliderPack slot 0.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [MIDI enabled for harmonic pitch distribution]

## Public Parameters

- Fundamental -> `PartialWriter.Value1` matched; range `[0, 1]`; default `0.5`
- Second -> `PartialWriter.Value2` matched; range `[0, 1]`; default `0.3`
- Third -> `PartialWriter.Value3` matched; range `[0, 1]`; default `0.2`

## Defaults To Omit

- `PartialWriter.Value1` default `0.0`
- `PartialWriter.Value2` default `0.0`
- `PartialWriter.Value3` default `0.0`

## Locked Build Values

- Clone, clone cable, and clone pack counts = `3`; clone mode = `Parallel`
- `PartialWriter.SliderPack` and `PartialLevels.SliderPack` external data index = `0`
- Interface pattern = `Synth.getSliderPackProcessor("ThreePartialAdditiveMixer").getSliderPack(0)`
- Writer resizes pack to `3`; Value1..Value3 map to indices `0..2`.
- `HarmonicPitch.Mode = Harmonics`; `SinePartial.Frequency` range = linear `[0, 20000]`
- `SinePartial.Mode = Sine`, Gate = `On`; PartialLevels target Gain `[0, 0.3]`

## Friction Comments To Weave In

- Before data setup: writer and clone pack share external slot 0 for deterministic initialization.
- Before writer connection: connection fixes pack size at three and each Value owns one zero-based index.
- Before frequency target: Harmonics mode requires MIDI and a linear 0..20 kHz target.

## Cosmetic Plan

- Main node: `PartialWriter`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`HarmonicPitch`, `PartialLevels`, `PartialBank`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`MidiContext`, `PartialVoice`]
- Nodes that must stay visible: [`PartialWriter`, `HarmonicPitch`, `PartialLevels`, `PartialBank`]

## Open Questions

- None
