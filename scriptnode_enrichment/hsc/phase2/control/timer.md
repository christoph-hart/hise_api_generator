# control.timer - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/timer.md`
- Reference: `scriptnode_enrichment/output/control/timer.md`

## Naming

- Module ID: `PeriodicToggleTremolo`
- Network ID: `periodic_toggle_tremolo`

## Graph Plan

```text
periodic_toggle_tremolo
  TremoloTimer           control.timer
  SquareGain             math.mul
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - HISE development use only; do not present this example as DAW or standalone export-safe.
- Channel/routing setup:
  - Required channels: default stereo in a monophonic effect context
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [timer must remain in audio-processing path]

## Public Parameters

- Interval -> `TremoloTimer.Interval` matched; range `[50, 1000]` ms; default `300`
- Active -> `TremoloTimer.Active` matched; Off/On; default `On`

## Defaults To Omit

- `TremoloTimer.Active` default `On`
- `TremoloTimer.Interval` default `500`
- `SquareGain.Value` default `1.0`

## Locked Build Values

- `TremoloTimer.Mode` property = `Toggle`
- `TremoloTimer.ClassId` = empty
- `TremoloTimer` output -> `SquareGain.Value` matched `[0, 1]`
- No smoothing between timer and gain.

## Friction Comments To Weave In

- Before builder setup: control.timer has a documented crash risk in exported DAW and standalone applications.
- Before `TremoloTimer`: the node counts processed samples and must remain in the realtime signal path.
- Before Active: enabling resets the counter and sends an initial value immediately.
- Before gain: hard binary transitions are intentional timing evidence.

## Cosmetic Plan

- Main node: `TremoloTimer`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`SquareGain`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`TremoloTimer`, `SquareGain`]

## Open Questions

- None
