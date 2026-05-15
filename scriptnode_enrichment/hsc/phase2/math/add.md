# math.add - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/add.md`
- Reference: `scriptnode_enrichment/output/math/add.md`

## Naming

- Module ID: `DcOffsetAdder`
- Network ID: `dc_offset_adder`

## Graph Plan

```text
dc_offset_adder
  SeedValue             math.add
  InputSpecs            analyse.specs
  OffsetAdder           math.add
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; a duplicated DC test signal is enough for the before/after readout
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Offset -> `OffsetAdder.Value` matched
- Target range before connection: `[0.0, 0.5]`
- Macro range: `[0.0, 0.5]`
- Default: `0.3`

## Defaults To Omit

- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `SeedValue`: seed a known non-zero input first so the target node demonstrates an actual offset instead of adding onto silence.

## Cosmetic Plan

- Main node: `OffsetAdder`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `OffsetAdder`, `OutputSpecs`]

## Open Questions

- None
