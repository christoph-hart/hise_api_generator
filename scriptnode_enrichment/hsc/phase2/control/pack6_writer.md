# control.pack6_writer - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/pack6_writer.md`
- Reference: `scriptnode_enrichment/output/control/pack6_writer.md`

## Naming

- Module ID: `SixBandParametricEq`
- Network ID: `six_band_parametric_eq`

## Graph Plan

```text
six_band_parametric_eq
  GainWriter             control.pack6_writer
  CentreFrequencies      control.clone_cable
  BandGains              control.clone_pack
  EqualiserBands         container.clone
    EqBand               container.chain
      PeakFilter         filters.svf_eq
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Duplicate one peak-EQ chain to six clones and initialize external SliderPack slot 0.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [serial clone mode cascades six EQ stages]

## Public Parameters

- Band1..Band6 -> `GainWriter.Value1..Value6`, macro range `[-18, 18]` dB mapped to target `[0, 1]`
- Defaults: all `0` dB

## Defaults To Omit

- `GainWriter.Value1..Value6` defaults `0.0`

## Locked Build Values

- Clone, clone-cable, and clone-pack counts = `6`; clone mode = `Serial`
- `GainWriter.SliderPack` and `BandGains.SliderPack` external data index = `0`
- Interface pattern = `Synth.getSliderPackProcessor("SixBandParametricEq").getSliderPack(0)`
- Writer resizes pack to `6`; Value1..Value6 map to indices `0..5`.
- `CentreFrequencies.Mode = Scale`; target `PeakFilter.Frequency` range `[100, 10000]`
- `BandGains` target = `PeakFilter.Gain`, range `[-18, 18]`
- `PeakFilter.Mode = Peak`, Q = `1.0`, Smoothing = `0.02`

## Friction Comments To Weave In

- Before `EqualiserBands`: Serial mode makes each EQ stage process the preceding band's output.
- Before public mapping: bipolar dB controls normalize into pack values before clone-pack target conversion.
- Before filter mode: Peak mode is required because LowPass and HighPass ignore Gain.

## Cosmetic Plan

- Main node: `GainWriter`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`CentreFrequencies`, `BandGains`, `EqualiserBands`, `PeakFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`EqBand`]
- Nodes that must stay visible: [`GainWriter`, `CentreFrequencies`, `BandGains`, `EqualiserBands`]

## Open Questions

- None
