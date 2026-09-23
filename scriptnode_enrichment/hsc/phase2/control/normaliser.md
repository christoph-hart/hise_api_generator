# control.normaliser - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/normaliser.md`
- Reference: `scriptnode_enrichment/output/control/normaliser.md`

## Naming

- Module ID: `TempoDurationDelayMix`
- Network ID: `tempo_duration_delay_mix`

## Graph Plan

```text
tempo_duration_delay_mix
  MusicalDuration        control.tempo_sync
  DurationNormaliser     control.normaliser
  EchoMix                template.dry_wet
    EchoMix_wet_path
      SyncedDelay        core.fix_delay
      EchoMix_wet_gain
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Replace the dry/wet template dummy and retain its wet gain as the final wet child.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Tempo -> `MusicalDuration.Tempo` matched
- Target range before connection: `[80, 180]`
- Macro range: `[80, 180]`
- Default: `120`
- Multiplier -> `MusicalDuration.Multiplier` matched
- Target range before connection: restricted divisions `1/16` through `1/4`
- Macro range: matching labelled divisions
- Default: `1/8`

## Defaults To Omit

- `DurationNormaliser.Value` default `0.0`

## Locked Build Values

- `MusicalDuration.Enabled` = `On`
- Supported durations = `[83.333, 750]` ms for locked public limits.
- `MusicalDuration` output -> `SyncedDelay.DelayTime` unscaled milliseconds
- `MusicalDuration` output -> `DurationNormaliser.Value` with range `[83.333, 750]`
- `DurationNormaliser` output -> `EchoMix.DryWet` range = `[0.15, 0.65]`
- `SyncedDelay.FadeTime` = `256` samples
- Wet-path order = `SyncedDelay`, `EchoMix_wet_gain`

## Friction Comments To Weave In

- Before `DurationNormaliser`: set its input range to the exact source millisecond domain; the node is not a unit converter.
- Before parallel connections: DelayTime receives raw milliseconds while DryWet receives normalized source position.
- Before wet path: preserve the template wet gain after the delay.

## Cosmetic Plan

- Main node: `DurationNormaliser`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`MusicalDuration`, `EchoMix`, `SyncedDelay`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`EchoMix_wet_gain`]
- Nodes that must stay visible: [`MusicalDuration`, `DurationNormaliser`, `EchoMix`, `SyncedDelay`]

## Open Questions

- None
