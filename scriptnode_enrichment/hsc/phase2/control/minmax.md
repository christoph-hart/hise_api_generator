# control.minmax - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/minmax.md`
- Reference: `scriptnode_enrichment/output/control/minmax.md`

## Naming

- Module ID: `AdjustableFilterSweepRange`
- Network ID: `adjustable_filter_sweep_range`

## Graph Plan

```text
adjustable_filter_sweep_range
  SweepControl           container.modchain
    SweepRamp            core.ramp
    FrequencyRange       control.minmax
  SweptFilter            filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Constrain UI controls so LowCutoff does not exceed HighCutoff.
- Channel/routing setup:
  - Required channels: default stereo; ramp uses isolated mono control processing
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- LowCutoff -> `FrequencyRange.Minimum` matched
- Target range before connection: `[100, 5000]`
- Macro range: `[100, 5000]`, skewed
- Default: `250`
- HighCutoff -> `FrequencyRange.Maximum` matched
- Target range before connection: `[500, 12000]`
- Macro range: `[500, 12000]`, skewed
- Default: `6000`
- Skew -> `FrequencyRange.Skew` matched
- Target range before connection: `[0.1, 10]`
- Macro range: `[0.1, 10]`
- Default: `2`

## Defaults To Omit

- `FrequencyRange.Value` default `0.0`
- `FrequencyRange.Step` default `0.0`
- `FrequencyRange.Polarity` default `Normal`

## Locked Build Values

- `SweepRamp.PeriodTime` = `1500`
- `SweepRamp` output -> `FrequencyRange.Value` matched over `[0, 1]`
- `FrequencyRange.Step` = `0`
- `FrequencyRange.Polarity` = `Normal`
- `FrequencyRange` output -> `SweptFilter.Frequency` unscaled Hz
- `SweptFilter.Mode` = `LowPass`, Q = `0.7`, Smoothing = `0.02`

## Friction Comments To Weave In

- Before `FrequencyRange`: output is raw Hz and must not receive another target range conversion.
- Before UI constraints: Minimum above Maximum intentionally reverses the range, so the canonical controls prevent it.
- Before Skew: endpoint frequencies stay fixed while only traversal shape changes.

## Cosmetic Plan

- Main node: `FrequencyRange`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`SweepRamp`, `SweptFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`SweepControl`]
- Nodes that must stay visible: [`SweepRamp`, `FrequencyRange`, `SweptFilter`]

## Open Questions

- None
