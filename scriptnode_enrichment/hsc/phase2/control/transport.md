# control.transport - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/transport.md`
- Reference: `scriptnode_enrichment/output/control/transport.md`

## Naming

- Module ID: `PlaybackOnlyFilter`
- Network ID: `playback_only_filter`

## Graph Plan

```text
playback_only_filter
  HostPlaying            control.transport
  PlaybackEffect         container.soft_bypass
    PlayingFilter        filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Test in a host that supplies real transport start and stop state.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- None

## Defaults To Omit

- None

## Locked Build Values

- `HostPlaying` output -> `PlaybackEffect.Bypass` matched `[0, 1]`
- `PlaybackEffect.SmoothingTime` property = `50` ms
- `PlayingFilter.Mode = LowPass`, Frequency = `1000`, Q = `0.7`, Smoothing = `0.02`

## Friction Comments To Weave In

- Before builder setup: standalone operation without DAW transport is not assumed.
- Before bypass connection: transport sends one for playing, which activates processing at the soft-bypass input.
- Before verification: output changes only when host play state changes, with no redundant polling updates.

## Cosmetic Plan

- Main node: `HostPlaying`
- Accent colour: `0xFF27AE60`
- Supporting relevant nodes: [`PlaybackEffect`, `PlayingFilter`]
- Supporting colour: `0xFF668A73`
- Folded nodes: []
- Nodes that must stay visible: [`HostPlaying`, `PlaybackEffect`, `PlayingFilter`]

## Open Questions

- None
