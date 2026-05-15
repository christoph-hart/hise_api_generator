# math.square - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/square.md`
- Reference: `scriptnode_enrichment/output/math/square.md`

## Naming

- Module ID: `SquaringCurveShaper`
- Network ID: `squaring_curve_shaper`

## Graph Plan

```text
squaring_curve_shaper
  SeedValue             math.add
  InputSpecs            analyse.specs
  SquareShape           math.square
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the scalar squaring test can stay duplicated on both lanes
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `SquareShape.Value` default `1.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `SquareShape`: mention that the exposed Value parameter has no effect, so the example teaches the fixed x*x transform only.

## Cosmetic Plan

- Main node: `SquareShape`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `SquareShape`, `OutputSpecs`]

## Open Questions

- None
