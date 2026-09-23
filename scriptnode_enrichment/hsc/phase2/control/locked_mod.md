# control.locked_mod - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/locked_mod.md`
- Reference: `scriptnode_enrichment/output/control/locked_mod.md`

## Naming

- Module ID: `ReusableLockedRamp`
- Network ID: `reusable_locked_ramp`

## Graph Plan

```text
reusable_locked_ramp
  RampModule             container.modchain [locked]
    RampRate             parameter
    InternalRamp         core.ramp
    ExposedRamp          control.locked_mod
  SweptFilter            filters.svf
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Lock `RampModule` only after its direct children and parameter are connected.
- Channel/routing setup:
  - Required channels: default stereo; locked module uses an isolated mono control buffer
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [locked container exposes modulation dragger]

## Public Parameters

- Rate -> `RampModule.RampRate` matched
- Target range before connection: `[200, 2000]`
- Macro range: `[200, 2000]`
- Default: `800`

## Defaults To Omit

- `ExposedRamp.Value` default `0.0`

## Locked Build Values

- `RampModule.RampRate` -> `InternalRamp.PeriodTime` matched over `[200, 2000]`
- `InternalRamp` output -> `ExposedRamp.Value` matched over `[0, 1]`
- Locked `RampModule` modulation output -> `SweptFilter.Frequency` range = `[200, 8000]`, skewed
- `SweptFilter.Mode` = `LowPass`
- `SweptFilter.Smoothing` = `0.02`
- `ExposedRamp` must be an immediate child of `RampModule`.

## Friction Comments To Weave In

- Before locking: locked_mod exposes its immediate parent's dragger only when it is a direct child.
- Before external connection: this normalised variant applies the target frequency range.
- Before `RampModule`: the modchain confines the ramp's generated signal to its control buffer.

## Cosmetic Plan

- Main node: `ExposedRamp`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`RampModule`, `InternalRamp`, `SweptFilter`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: [`InternalRamp`, `ExposedRamp`]
- Nodes that must stay visible: [`RampModule`, `SweptFilter`]

## Open Questions

- None
