# control.bang - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/bang.md`
- Reference: `scriptnode_enrichment/output/control/bang.md`

## Naming

- Module ID: `DesynchronisedSampleHold`
- Network ID: `desynchronised_sample_hold`

## Graph Plan

```text
desynchronised_sample_hold
  SampleControl          container.modchain
    SourceRamp           core.ramp
    TriggerTimer         control.timer
    HeldValue            control.bang
  CutoffNormaliser       control.normaliser
  SteppedFilter          filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - HISE development use only; do not present this timer-based example as export-safe.
- Channel/routing setup:
  - Required channels: default stereo; source and trigger live in the isolated mono modchain
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [development-only timer constraint]

## Public Parameters

- RampPeriod -> `SourceRamp.PeriodTime` matched
- Target range before connection: `[200, 2000]`
- Macro range: `[200, 2000]`
- Default: `700`
- TriggerInterval -> `TriggerTimer.Interval` matched
- Target range before connection: `[50, 500]`
- Macro range: `[50, 500]`
- Default: `230`

## Defaults To Omit

- `HeldValue.Value` default `0.0`
- `HeldValue.Bang` default `Off`

## Locked Build Values

- `TriggerTimer.Mode` property = `Ping`
- `SourceRamp.PeriodTime` = `700`
- `TriggerTimer.Interval` = `230`
- `SourceRamp` output -> `HeldValue.Value` raw connection over `[0, 1]`
- `TriggerTimer` output -> `HeldValue.Bang` raw connection over `[0, 1]`
- `HeldValue` output -> `CutoffNormaliser.Value`
- `CutoffNormaliser` output -> `SteppedFilter.Frequency`
- `SteppedFilter.Frequency` range = `[200, 8000]`, skewed
- `SteppedFilter.Mode` = `LowPass`
- `SteppedFilter.Smoothing` = `0.02`

## Friction Comments To Weave In

- Before `HeldValue`: Value only updates stored state; output changes only when Bang receives a value above 0.5.
- Before period settings: the non-integer period ratio samples a different ramp phase on successive timer pings.
- Before builder setup: control.timer has a documented crash risk outside HISE development use.

## Cosmetic Plan

- Main node: `HeldValue`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`SourceRamp`, `TriggerTimer`, `CutoffNormaliser`, `SteppedFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`SampleControl`, `SourceRamp`, `TriggerTimer`, `HeldValue`, `CutoffNormaliser`, `SteppedFilter`]
- `SampleControl.ShowParameters` = `true` so root parameter cables to inner nodes remain visible

## Open Questions

- None
