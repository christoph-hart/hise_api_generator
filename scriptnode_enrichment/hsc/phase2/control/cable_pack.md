# control.cable_pack - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/cable_pack.md`
- Reference: `scriptnode_enrichment/output/control/cable_pack.md`

## Naming

- Module ID: `TempoSyncedFilterSteps`
- Network ID: `tempo_synced_filter_steps`

## Graph Plan

```text
tempo_synced_filter_steps
  BarPlayhead            core.clock_ramp
  StepLookup             control.cable_pack
  SequencedFilter        filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Create Interface `onInit` code that obtains SliderPack slot 0 and writes all eight startup values.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None; the external eight-slider pack is the public sequence editor.

## Defaults To Omit

- `StepLookup.Value` default `0.0`

## Locked Build Values

- `StepLookup.SliderPack` external data index = `0`
- Interface `onInit`: `const var stepProcessor = Synth.getSliderPackProcessor("TempoSyncedFilterSteps");`
- Interface `onInit`: `const var stepData = stepProcessor.getSliderPack(0);`
- SliderPack size = `8`
- Startup values = `[0.15, 0.75, 0.35, 0.9, 0.25, 0.6, 0.45, 1.0]`
- `BarPlayhead.Mode` = `Synced`
- `BarPlayhead.AddToSignal` = `Off`
- `BarPlayhead.Multiplier` = `1 Bar`
- `BarPlayhead.Inactive` = `0`
- `BarPlayhead` output -> `StepLookup.Value` matched over `[0, 1]`
- `StepLookup` output -> `SequencedFilter.Frequency` range = `[200, 8000]`
- `SequencedFilter.Mode` = `LowPass`
- `SequencedFilter.Smoothing` = `0.01`

## Friction Comments To Weave In

- Before complex-data setup: use external slot 0 because Interface script cannot write embedded pack data.
- Before `StepLookup`: nearest-neighbour lookup creates eight held zones without interpolation.
- Before endpoint verification: the normalised endpoint must resolve to the final slider without indexing beyond the pack.

## Cosmetic Plan

- Main node: `StepLookup`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`BarPlayhead`, `SequencedFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`BarPlayhead`, `StepLookup`, `SequencedFilter`]

## Open Questions

- None
