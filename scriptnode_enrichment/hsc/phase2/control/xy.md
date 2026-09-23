# control.xy - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/xy.md`
- Reference: `scriptnode_enrichment/output/control/xy.md`

## Naming

- Module ID: `FilterPanXyPad`
- Network ID: `filter_pan_xy_pad`

## Graph Plan

```text
filter_pan_xy_pad
  FilterPanPad           control.xy
  XFilter                filters.svf
  YPanner                jdsp.jpanner
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Bind X and Y to one Interface XY pad while preserving each native axis range.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- X -> `FilterPanPad.X` matched; target and macro range `[0, 1]`; default `0.5`
- Y -> `FilterPanPad.Y` matched; target and macro range `[-1, 1]`; default `0`

## Defaults To Omit

- `FilterPanPad.X` default `0.0`
- `FilterPanPad.Y` default `0.0`

## Locked Build Values

- Output X -> `XFilter.Frequency` range = `[200, 8000]`, skewed
- Output Y -> `YPanner.Pan` unscaled bipolar range = `[-1, 1]`
- `XFilter.Mode = LowPass`, Q = `0.7`, Smoothing = `0.02`
- `YPanner.Rule` = `ConstantPower`

## Friction Comments To Weave In

- Before output connections: X is unipolar output slot 0 while Y is already bipolar output slot 1.
- Before Y target: do not normalize the bipolar axis a second time.
- Before verification: test all corners and centre to prove axis independence.

## Cosmetic Plan

- Main node: `FilterPanPad`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`XFilter`, `YPanner`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`FilterPanPad`, `XFilter`, `YPanner`]

## Open Questions

- None
