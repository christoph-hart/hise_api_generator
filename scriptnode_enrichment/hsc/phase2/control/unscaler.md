# control.unscaler - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/unscaler.md`
- Reference: `scriptnode_enrichment/output/control/unscaler.md`

## Naming

- Module ID: `ExactMillisecondBroadcast`
- Network ID: `exact_millisecond_broadcast`

## Graph Plan

```text
exact_millisecond_broadcast
  RawDelayTime           control.unscaler
  FirstDelay             core.fix_delay
  SecondDelay            core.fix_delay
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- DelayTime -> `RawDelayTime.Value` matched
- Target range before connection: `[1, 500]` ms
- Macro range: `[1, 500]` ms
- Default: `120`

## Defaults To Omit

- `RawDelayTime.Value` default `0.0`

## Locked Build Values

- `RawDelayTime.Value` range = `[1, 500]` ms
- `RawDelayTime` output -> both DelayTime targets unscaled
- `FirstDelay.FadeTime` = `256` samples
- `SecondDelay.FadeTime` = `256` samples
- Both delays must report the exact same native millisecond value.

## Friction Comments To Weave In

- Before `RawDelayTime`: this node performs no smoothing or unit conversion and bypasses target range mapping.
- Before both connections: one raw millisecond value is broadcast unchanged to both serial stages.
- Before verification: include values above 1 to prove the signal is not normalized.

## Cosmetic Plan

- Main node: `RawDelayTime`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`FirstDelay`, `SecondDelay`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`RawDelayTime`, `FirstDelay`, `SecondDelay`]

## Open Questions

- None
