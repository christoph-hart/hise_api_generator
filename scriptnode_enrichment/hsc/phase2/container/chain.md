# container.chain - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/chain.md`
- Reference: `scriptnode_enrichment/output/container/chain.md`

## Naming

- Module ID: `NestedMacroChain`
- Network ID: `nested_macro_chain`

## Graph Plan

```text
nested_macro_chain
  SweepControl           container.modchain
    SweepRamp            core.ramp
    SweepPeak            core.peak
  FilterAndLevel         container.chain
    Sweep                parameter
    GainInverter         control.pma
    MovingFilter         filters.svf
    OutputLevel          core.gain
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; `SweepControl` uses its isolated mono control buffer
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [isolated mono modulation path]

## Public Parameters

- Sweep -> `FilterAndLevel.Sweep` range `[0, 1]`, default `0`

## Defaults To Omit

- `GainInverter.Value` default `0.0`
- `MovingFilter.Mode` default `LowPass`
- `MovingFilter.Q` default `1.0`
- `OutputLevel.Smoothing` default `20.0`

## Locked Build Values

- `SweepRamp.PeriodTime` range = `[0.1, 2000]`
- `SweepRamp.PeriodTime` = `2000`
- `GainInverter.Multiply` = `-1`
- `GainInverter.Add` = `1`
- `MovingFilter.Mode` = `LowPass`
- `MovingFilter.Smoothing` = `0.02`
- `FilterAndLevel.Sweep` range = `[0, 1]`
- `FilterAndLevel.Sweep -> MovingFilter.Frequency` scaled to `[200, 8000]`
- `FilterAndLevel.Sweep -> GainInverter.Value` matched over `[0, 1]`
- `GainInverter` output -> `OutputLevel.Gain` scaled to `[-12, -3]`
- `SweepPeak` modulation output -> `FilterAndLevel.Sweep` range = `[0, 1]`

## Friction Comments To Weave In

- Before `SweepControl`: the modchain keeps the generated ramp out of the audible stereo path.
- Before `FilterAndLevel.Sweep`: the inner macro is the modulation boundary and fans one source out to two nested targets.
- Before `GainInverter`: invert Sweep with PMA instead of reversing the Gain target range; a reversed target would also reverse the shared macro range used by the filter connection.
- Before the gain connection: the inverted PMA output lowers gain as the filter opens.

## Cosmetic Plan

- Main node: `FilterAndLevel`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SweepControl`, `SweepPeak`, `GainInverter`, `MovingFilter`, `OutputLevel`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SweepRamp`]
- Nodes that must stay visible: [`SweepControl`, `FilterAndLevel`, `SweepPeak`, `GainInverter`, `MovingFilter`, `OutputLevel`]

## Open Questions

- None
