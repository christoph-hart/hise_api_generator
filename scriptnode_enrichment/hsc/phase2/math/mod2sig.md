# math.mod2sig - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/mod2sig.md`
- Reference: `scriptnode_enrichment/output/math/mod2sig.md`

## Naming

- Module ID: `UnipolarToBipolar`
- Network ID: `unipolar_to_bipolar`

## Graph Plan

```text
unipolar_to_bipolar
  SeedValue             math.add
  InputSpecs            analyse.specs
  RangeConverter        math.mod2sig
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; a duplicated unipolar test value is enough for the conversion check
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `RangeConverter.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `SeedValue`: keep the seeded value inside 0..1 so the example stays about modulation-range conversion rather than out-of-range behaviour.

## Cosmetic Plan

- Main node: `RangeConverter`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `RangeConverter`, `OutputSpecs`]

## Open Questions

- None
