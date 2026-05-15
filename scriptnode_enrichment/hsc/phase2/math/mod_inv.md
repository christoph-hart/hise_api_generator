# math.mod_inv - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/mod_inv.md`
- Reference: `scriptnode_enrichment/output/math/mod_inv.md`

## Naming

- Module ID: `ModulationInverter`
- Network ID: `modulation_inverter`

## Graph Plan

```text
modulation_inverter
  SeedValue             math.add
  InputSpecs            analyse.specs
  InvertModulation      math.mod_inv
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the inversion is shown with a duplicated 0..1 test signal
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- `InvertModulation.Value` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `InvertModulation`: note that this flips a unipolar 0..1 signal around one-half, not around zero like `math.inv`.

## Cosmetic Plan

- Main node: `InvertModulation`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `InvertModulation`, `OutputSpecs`]

## Open Questions

- None
