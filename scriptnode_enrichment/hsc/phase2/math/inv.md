# math.inv - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/inv.md`
- Reference: `scriptnode_enrichment/output/math/inv.md`

## Naming

- Module ID: `SignalPolarityInverter`
- Network ID: `signal_polarity_inverter`

## Graph Plan

```text
signal_polarity_inverter
  SeedValue             math.add
  InputSpecs            analyse.specs
  InvertPolarity        math.inv
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; a duplicated scalar test signal is enough to show the sign flip
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `InvertPolarity.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `SeedValue`: use a non-zero seed so the inversion stays visible in the analyser readout.

## Cosmetic Plan

- Main node: `InvertPolarity`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `InvertPolarity`, `OutputSpecs`]

## Open Questions

- None
