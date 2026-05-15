# math.pow - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/pow.md`
- Reference: `scriptnode_enrichment/output/math/pow.md`

## Naming

- Module ID: `ExponentCurveShaper`
- Network ID: `exponent_curve_shaper`

## Graph Plan

```text
exponent_curve_shaper
  SeedValue             math.add
  InputSpecs            analyse.specs
  PowerShape            math.pow
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; a duplicated non-negative seed is enough for the curve check
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `PowerShape.Value` default `1.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `SeedValue`: keep the test input non-negative because negative values can become NaN here.

## Cosmetic Plan

- Main node: `PowerShape`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `PowerShape`, `OutputSpecs`]

## Open Questions

- None
