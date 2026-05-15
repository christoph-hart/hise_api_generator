# math.sub - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/sub.md`
- Reference: `scriptnode_enrichment/output/math/sub.md`

## Naming

- Module ID: `DcSubtractor`
- Network ID: `dc_subtractor`

## Graph Plan

```text
dc_subtractor
  SeedValue             math.add
  InputSpecs            analyse.specs
  OffsetSubtractor      math.sub
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; a duplicated constant test signal is enough for the subtraction readout
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Offset -> `OffsetSubtractor.Value` matched
- Target range before connection: `[0.0, 0.5]`
- Macro range: `[0.0, 0.5]`
- Default: `0.2`

## Defaults To Omit

- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `SeedValue`: seed a known non-zero input first so the subtraction result is visible in the analyser.

## Cosmetic Plan

- Main node: `OffsetSubtractor`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `OffsetSubtractor`, `OutputSpecs`]

## Open Questions

- None
