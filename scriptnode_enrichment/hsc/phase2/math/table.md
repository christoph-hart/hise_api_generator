# math.table - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/table.md`
- Reference: `scriptnode_enrichment/output/math/table.md`

## Naming

- Module ID: `DrawnTransferShaper`
- Network ID: `drawn_transfer_shaper`

## Graph Plan

```text
drawn_transfer_shaper
  SlowRamp              core.ramp
  TableLookup           math.table
  OutputPeak            core.peak
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the lookup scan can stay mirrored on both lanes
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `OutputPeak.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before the complex-data setup: this node has no automatable parameters, so the public interaction is the drawn table itself rather than a matched root macro.
- Before `TableLookup`: keep the input in 0..1 because the node clamps its lookup domain.

## Cosmetic Plan

- Main node: `TableLookup`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SlowRamp`, `OutputPeak`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SlowRamp`, `TableLookup`, `OutputPeak`]

## Open Questions

- None
