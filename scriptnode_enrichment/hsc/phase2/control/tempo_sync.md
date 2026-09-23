# control.tempo_sync - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/tempo_sync.md`
- Reference: `scriptnode_enrichment/output/control/tempo_sync.md`

## Naming

- Module ID: `HostSynchronisedEcho`
- Network ID: `host_synchronised_echo`

## Graph Plan

```text
host_synchronised_echo
  EchoDuration           control.tempo_sync
  EchoMix                template.dry_wet
    EchoMix_wet_path
      EchoDelay          core.fix_delay
      EchoMix_wet_gain
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Replace the template dummy and preserve the wet gain after the delay.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Tempo -> `EchoDuration.Tempo` matched; restricted labelled divisions `1/16` through `1/4`; default `1/8`
- Multiplier -> `EchoDuration.Multiplier` matched; range `[1, 2]`, step `1`; default `1`
- SyncEnabled -> `EchoDuration.Enabled` matched; Off/On; default `On`
- UnsyncedTime -> `EchoDuration.UnsyncedTime` matched; range `[20, 1000]` ms; default `250`
- Mix -> `EchoMix.DryWet` matched; range `[0, 1]`; default `0.35`

## Defaults To Omit

- `EchoDuration.Multiplier` default `1`
- `EchoDuration.Enabled` default `Off`
- `EchoDuration.UnsyncedTime` default `200`

## Locked Build Values

- `EchoDuration.Enabled` startup = `On`
- Supported division, multiplier, and BPM combinations must stay within `EchoDelay.DelayTime <= 1000` ms.
- `EchoDuration` output -> `EchoDelay.DelayTime` unscaled milliseconds
- `EchoDelay.FadeTime` = `256` samples
- Wet-path order = `EchoDelay`, `EchoMix_wet_gain`; dry/wet law = `linear`

## Friction Comments To Weave In

- Before `EchoDuration`: output is raw milliseconds and connects directly to DelayTime without normalisation.
- Before Enabled: the node defaults off, so canonical startup explicitly enables host sync.
- Before FadeTime: delay-time changes crossfade over samples, while the source duration is milliseconds.
- Before wet path: retain the template wet gain as the final child.

## Cosmetic Plan

- Main node: `EchoDuration`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`EchoMix`, `EchoDelay`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`EchoMix_wet_gain`]
- Nodes that must stay visible: [`EchoDuration`, `EchoMix`, `EchoDelay`]

## Open Questions

- None
