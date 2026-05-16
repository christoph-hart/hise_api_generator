# dynamics.envelope_follower - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/dynamics/envelope_follower.md`
- Reference: `scriptnode_enrichment/output/dynamics/envelope_follower.md`

## Naming

- Module ID: `DynamicMidCut`
- Network ID: `dynamic_mid_cut`

## Graph Plan

```text
dynamic_mid_cut
  TimingBlock           container.fix16_block
    InputFollower       dynamics.envelope_follower
    HarshBandEQ         filters.svf_eq
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo; the follower analyses the same stereo program signal it leaves in place
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [fixed block wrapper is deliberate because follower modulation drives an EQ parameter and should update at a deterministic interval]

## Public Parameters

- FollowerAttack -> `InputFollower.Attack` matched
- Target range before connection: `[5, 80]`
- Macro range: `[5, 80]`
- Default: `20`
- FollowerRelease -> `InputFollower.Release` matched
- Target range before connection: `[40, 300]`
- Macro range: `[40, 300]`
- Default: `120`
- MidCutDepth -> `HarshBandEQ.Gain` matched
- Target range before connection: `[-18, -3]`
- Macro range: `[-18, -3]`
- Default: `-9`

## Defaults To Omit

- `InputFollower.ProcessSignal` default `Off`

## Locked Build Values

- None

## Friction Comments To Weave In

- Before `TimingBlock`: the fixed-block container is intentional because the follower's exported modulation drives `HarshBandEQ.Gain` and should update at a deterministic interval.
- Before the modulation connection to `HarshBandEQ.Gain`: narrow and invert the follower's 0..1 output so louder playing creates attenuation instead of boost.
- Before `set InputFollower.ProcessSignal`: keep it `Off` so the node analyses the source without replacing the audio signal.

## Cosmetic Plan

- Main node: `InputFollower`
- Accent colour: `0xFFE67E22`
- Supporting relevant nodes: [`TimingBlock`, `HarshBandEQ`]
- Supporting colour: `0xFF8F7766`
- Folded nodes: []
- Nodes that must stay visible: [`TimingBlock`, `InputFollower`, `HarshBandEQ`]

## Open Questions

- None
