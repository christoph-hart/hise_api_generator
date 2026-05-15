# math.abs - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/abs.md`
- Reference: `scriptnode_enrichment/output/math/abs.md`

## Naming

- Module ID: `FoldedTriangleShaper`
- Network ID: `folded_triangle_shaper`

## Graph Plan

```text
folded_triangle_shaper
  SlowRamp              core.ramp
  BipolarOffset         math.add
  BipolarScale          math.mul
  FoldShape             math.abs
  OutputPeak            core.peak
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; both lanes carry the same slow control-shape signal for the display
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `FoldShape.Value` default `0.0`
- `OutputPeak.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `BipolarOffset` and `BipolarScale`: make the ramp bipolar before `math.abs`, otherwise the node only sees an already non-negative 0..1 signal.

## Cosmetic Plan

- Main node: `FoldShape`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`BipolarOffset`, `BipolarScale`, `OutputPeak`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SlowRamp`, `BipolarOffset`, `BipolarScale`, `FoldShape`, `OutputPeak`]

## Open Questions

- None
