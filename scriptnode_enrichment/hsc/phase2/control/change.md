# control.change - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/change.md`
- Reference: `scriptnode_enrichment/output/control/change.md`

## Naming

- Module ID: `DuplicateFreeFourStepSweep`
- Network ID: `duplicate_free_four_step_sweep`

## Graph Plan

```text
duplicate_free_four_step_sweep
  StepControl            container.modchain
    SourceRamp           core.ramp
    FourLevelQuantiser   control.cable_expr
    DistinctValues       control.change
    CutoffNormalise      control.normaliser
  SteppedFilter          filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Enable compilation for the SNEX quantiser expression.
- Channel/routing setup:
  - Required channels: default stereo; control path uses isolated mono processing
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `FourLevelQuantiser.Value` default `0.0`
- `DistinctValues.Value` default `0.0`

## Locked Build Values

- `SourceRamp.PeriodTime` = `1000`
- `FourLevelQuantiser.Code` = `Math.min(Math.floor(input * 4.0), 3.0) / 3.0`
- `SourceRamp` output -> `FourLevelQuantiser.Value` matched over `[0, 1]`
- `FourLevelQuantiser` output -> `DistinctValues.Value` unscaled
- `DistinctValues` output -> `CutoffNormalise.Value` raw connection over `[0, 1]`
- `CutoffNormalise` output -> `SteppedFilter.Frequency` range = `[300, 6000]`
- `SteppedFilter.Mode` = `LowPass`
- `SteppedFilter.Q` = `0.7`
- `SteppedFilter.Smoothing` = `0.01`

## Friction Comments To Weave In

- Before `FourLevelQuantiser`: the endpoint-safe formula emits exactly four bit-identical plateau values.
- Before `DistinctValues`: exact duplicate comparison has no tolerance and the initial stored zero suppresses the first incoming zero.
- Before `CutoffNormalise`: the change output is raw 0..1, so normalize it before the filter frequency mapping.
- Before verification: trace quantiser and change outputs together to distinguish repeated upstream values from forwarded transitions.

## Cosmetic Plan

- Main node: `DistinctValues`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`SourceRamp`, `FourLevelQuantiser`, `CutoffNormalise`, `SteppedFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`StepControl`, `SourceRamp`, `FourLevelQuantiser`, `DistinctValues`, `CutoffNormalise`, `SteppedFilter`]

## Open Questions

- None
