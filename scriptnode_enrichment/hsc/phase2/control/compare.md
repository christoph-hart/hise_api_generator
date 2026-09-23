# control.compare - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/compare.md`
- Reference: `scriptnode_enrichment/output/control/compare.md`

## Naming

- Module ID: `MinimumCutoffGuard`
- Network ID: `minimum_cutoff_guard`

## Graph Plan

```text
minimum_cutoff_guard
  CutoffMaximum          control.compare
  GuardedFilter          filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Frequency -> `CutoffMaximum.Left` through inverse normalisation
- Target range before connection: `[0, 1]`
- Macro range: `[200, 8000]`, skewed
- Default: `2000`
- MinimumFrequency -> `CutoffMaximum.Right` through inverse normalisation
- Target range before connection: `[0, 1]`
- Macro range: `[200, 8000]`, skewed
- Default: `500`

## Defaults To Omit

- `CutoffMaximum.Left` default `0.0`
- `CutoffMaximum.Right` default `0.0`
- `CutoffMaximum.Comparator` default `EQ`

## Locked Build Values

- `CutoffMaximum.Comparator` = `MAX`
- Both public frequency controls map to identical normalised `[0, 1]` operands.
- `CutoffMaximum` output -> `GuardedFilter.Frequency` range = `[200, 8000]`, skewed
- `GuardedFilter.Mode` = `LowPass`
- `GuardedFilter.Q` = `0.7`
- `GuardedFilter.Smoothing` = `0.02`

## Friction Comments To Weave In

- Before public mapping: both frequency controls must be inverse-mapped into the same 0..1 operand domain.
- Before `CutoffMaximum`: MAX returns the larger continuous value, not a boolean result.
- Before verification: test above, below, and equal operands.

## Cosmetic Plan

- Main node: `CutoffMaximum`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`GuardedFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`CutoffMaximum`, `GuardedFilter`]

## Open Questions

- None
