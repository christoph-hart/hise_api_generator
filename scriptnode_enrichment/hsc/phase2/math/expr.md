# math.expr - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/expr.md`
- Reference: `scriptnode_enrichment/output/math/expr.md`

## Naming

- Module ID: `ProgrammableScalarTransform`
- Network ID: `programmable_scalar_transform`

## Graph Plan

```text
programmable_scalar_transform
  SeedValue             math.add
  InputSpecs            analyse.specs
  ShapeExpr             math.expr
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the expression is validated with a duplicated known test signal
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- ClipWidth -> `ShapeExpr.Value` matched
- Target range before connection: `[0.2, 0.8]`
- Macro range: `[0.2, 0.8]`
- Default: `0.4`

## Defaults To Omit

- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `set_property Code`: use a tiny one-line SNEX formula such as `Math.range(input, -1.0f * value, 1.0f * value)` so the node teaches programmability without extra graph clutter.
- Before `set_property Code`: use explicit float literals with the `f` suffix to avoid SNEX type mismatch warnings.

## Cosmetic Plan

- Main node: `ShapeExpr`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `ShapeExpr`, `OutputSpecs`]

## Open Questions

- None
