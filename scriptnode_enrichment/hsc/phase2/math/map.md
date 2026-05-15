# math.map - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/math/map.md`
- Reference: `scriptnode_enrichment/output/math/map.md`

## Naming

- Module ID: `ClampedRangeMapper`
- Network ID: `clamped_range_mapper`

## Graph Plan

```text
clamped_range_mapper
  SeedValue             math.add
  InputSpecs            analyse.specs
  RangeMapper           math.map
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the clamped mapping is demonstrated with a duplicated known input value
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- InputEnd -> `RangeMapper.InputEnd` matched
- Target range before connection: `[0.4, 0.8]`
- Macro range: `[0.4, 0.8]`
- Default: `0.6`
- OutputStart -> `RangeMapper.OutputStart` matched
- Target range before connection: `[0.0, 0.3]`
- Macro range: `[0.0, 0.3]`
- Default: `0.2`
- OutputEnd -> `RangeMapper.OutputEnd` matched
- Target range before connection: `[0.6, 1.0]`
- Macro range: `[0.6, 1.0]`
- Default: `0.9`

## Defaults To Omit

- `RangeMapper.InputStart` default `0.0`
- `SignalClear.Value` default `0.0`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `create_parameter`: raw 0..1 control ranges are too broad for this example, so narrow the mapping bounds to the exact clamped remap the scenario is trying to explain.

## Cosmetic Plan

- Main node: `RangeMapper`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`SeedValue`, `InputSpecs`, `OutputSpecs`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`SignalClear`]
- Nodes that must stay visible: [`SeedValue`, `InputSpecs`, `RangeMapper`, `OutputSpecs`]

## Open Questions

- None
