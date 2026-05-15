# math.sqrt - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/sqrt.md`
- Reference: `scriptnode_enrichment/output/math/sqrt.md`

## Naming

- Module ID: `RootCurveShaper`
- Network ID: `root_curve_shaper`

## Graph Plan

```text
root_curve_shaper
  SeedValue             math.add
  InputSpecs            analyse.specs
  RootShape             math.sqrt
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; a duplicated non-negative seed is enough for the before/after check
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `RootShape.Value` default `1.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `SeedValue`: keep the input non-negative because negative values produce NaN.

## Cosmetic Plan

- Main node: `RootShape`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `RootShape`, `OutputSpecs`]

## Open Questions

- None
