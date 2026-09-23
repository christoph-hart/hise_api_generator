# control.logic_op - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/logic_op.md`
- Reference: `scriptnode_enrichment/output/control/logic_op.md`

## Naming

- Module ID: `TransportUserEnable`
- Network ID: `transport_user_enable`

## Graph Plan

```text
transport_user_enable
  PlayingState           control.transport
  CombinedEnable         control.logic_op
  ConditionalEffect      container.soft_bypass
    PlaybackFilter       filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Explicitly initialize both logic operands after reset.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Enable -> `CombinedEnable.Right` matched
- Target range before connection: `[0, 1]`, step `1`
- Macro range: `[0, 1]`, step `1`, labels `Off, On`
- Default: `1`

## Defaults To Omit

- `CombinedEnable.Operator` default `AND`
- `CombinedEnable.Left` default `0.0`
- `CombinedEnable.Right` default `0.0`

## Locked Build Values

- `CombinedEnable.Operator` = `AND`
- `PlayingState` output -> `CombinedEnable.Left` matched over `[0, 1]`
- `CombinedEnable` output -> `ConditionalEffect.Bypass` matched over `[0, 1]`
- `ConditionalEffect.SmoothingTime` property = `40` ms
- `PlaybackFilter.Mode` = `LowPass`
- `PlaybackFilter.Frequency` = `1200`
- Both operands must receive explicit startup values before output is expected.

## Friction Comments To Weave In

- Before initialization: logic_op emits nothing until both operands have each received a value after reset.
- Before `CombinedEnable`: values above 0.5 are true, but the example sends strict zero or one.
- Before bypass connection: output one activates soft-bypass processing rather than bypassing it.

## Cosmetic Plan

- Main node: `CombinedEnable`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`PlayingState`, `ConditionalEffect`, `PlaybackFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`PlayingState`, `CombinedEnable`, `ConditionalEffect`, `PlaybackFilter`]

## Open Questions

- None
