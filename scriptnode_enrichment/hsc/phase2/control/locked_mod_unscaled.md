# control.locked_mod_unscaled - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/locked_mod_unscaled.md`
- Reference: `scriptnode_enrichment/output/control/locked_mod_unscaled.md`

## Naming

- Module ID: `ReusableTempoDuration`
- Network ID: `reusable_tempo_duration`

## Graph Plan

```text
reusable_tempo_duration
  DurationModule         container.modchain [locked]
    Tempo                parameter
    Multiplier           parameter
    MusicalDuration      control.tempo_sync
    ExposedDuration      control.locked_mod_unscaled
  SyncedDelay            core.fix_delay
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Lock `DurationModule` after direct-child connections are complete.
- Channel/routing setup:
  - Required channels: default stereo; duration module uses isolated mono control processing
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [locked container exports raw milliseconds]

## Public Parameters

- Tempo -> `DurationModule.Tempo` matched
- Target range before connection: `[80, 180]`
- Macro range: `[80, 180]`
- Default: `120`
- Multiplier -> `DurationModule.Multiplier` matched
- Target range before connection: restricted divisions from `1/16` through `1/4`
- Macro range: matching labelled divisions
- Default: `1/8`

## Defaults To Omit

- `ExposedDuration.Value` default `0.0`

## Locked Build Values

- `MusicalDuration.Enabled` = `On`
- Public controls connect to matching `MusicalDuration` parameters.
- `ExposedDuration.Value` range = `[0, 1000]`
- `MusicalDuration` output -> `ExposedDuration.Value` unscaled
- Locked `DurationModule` output -> `SyncedDelay.DelayTime` unscaled
- `SyncedDelay.FadeTime` = `256` samples
- Supported Tempo and Multiplier combinations must remain at or below `1000` ms.

## Friction Comments To Weave In

- Before locking: the unscaled exporter must be an immediate child of the locked parent.
- Before delay connection: raw milliseconds must bypass target range conversion or they would be scaled twice.
- Before FadeTime: this parameter is measured in samples although DelayTime is milliseconds.

## Cosmetic Plan

- Main node: `ExposedDuration`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`DurationModule`, `MusicalDuration`, `SyncedDelay`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`MusicalDuration`, `ExposedDuration`]
- Nodes that must stay visible: [`DurationModule`, `SyncedDelay`]

## Open Questions

- None
