# math.mul - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/mul.md`
- Reference: `scriptnode_enrichment/output/math/mul.md`

## Naming

- Module ID: `ScalarGainMultiplier`
- Network ID: `scalar_gain_multiplier`

## Graph Plan

```text
scalar_gain_multiplier
  SeedValue             math.add
  InputSpecs            analyse.specs
  GainScale             math.mul
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; a duplicated constant test value is enough for the linear gain demonstration
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Multiplier -> `GainScale.Value` matched
- Target range before connection: `[0.0, 1.0]`
- Macro range: `[0.0, 1.0]`
- Default: `0.5`

## Defaults To Omit

- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `GainScale`: call out that this is raw linear scaling, not decibel gain control.

## Cosmetic Plan

- Main node: `GainScale`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `GainScale`, `OutputSpecs`]

## Open Questions

- None
