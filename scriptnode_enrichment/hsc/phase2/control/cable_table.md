# control.cable_table - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/cable_table.md`
- Reference: `scriptnode_enrichment/output/control/cable_table.md`

## Naming

- Module ID: `ShapedFilterComparison`
- Network ID: `shaped_filter_comparison`

## Graph Plan

```text
shaped_filter_comparison
  CutoffShape            control.cable_table
  ChannelComparison      container.multi
    LinearChannel        container.chain
      LinearFilter       filters.svf
    ShapedChannel        container.chain
      ShapedFilter       filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Create Interface `onInit` code that obtains Table slot 0 and writes a monotonic skewed curve.
  - Use duplicated mono source material for left/right verification.
- Channel/routing setup:
  - Required channels: exactly 2; left is linear reference and right is table-shaped
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [one mono comparison path per stereo channel]

## Public Parameters

- Cutoff -> `CutoffShape.Value` and `LinearFilter.Frequency` through matched normalised mapping
- Target range before connection: internal `[0, 1]`; filter targets `[200, 8000]`
- Macro range: `[200, 8000]`, skewed
- Default: `1000`

## Defaults To Omit

- `CutoffShape.Value` default `0.0`

## Locked Build Values

- `CutoffShape.Table` external data index = `0`
- Interface `onInit`: `const var tableProcessor = Synth.getTableProcessor("ShapedFilterComparison");`
- Interface `onInit`: `const var tableData = tableProcessor.getTable(0);`
- Table startup points preserve `(0, 0)` and `(1, 1)` with midpoint `(0.5, 0.25)`.
- Both filters: `Mode = LowPass`, `Q = 0.7`, `Smoothing = 0.02`, Frequency range `[200, 8000]`
- `CutoffShape` output -> `ShapedFilter.Frequency` range = `[200, 8000]`

## Friction Comments To Weave In

- Before routing setup: multi gives each filter one non-overlapping channel for simultaneous comparison.
- Before complex-data setup: external slot 0 permits deterministic Interface-script initialization.
- Before `CutoffShape`: the 512-point table uses linear interpolation, preserving smooth movement despite nonlinear remapping.

## Cosmetic Plan

- Main node: `CutoffShape`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`ChannelComparison`, `LinearFilter`, `ShapedFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`LinearChannel`, `ShapedChannel`]
- Nodes that must stay visible: [`CutoffShape`, `ChannelComparison`, `LinearFilter`, `ShapedFilter`]

## Open Questions

- None
