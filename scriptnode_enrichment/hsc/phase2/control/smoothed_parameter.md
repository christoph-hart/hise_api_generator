# control.smoothed_parameter - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/smoothed_parameter.md`
- Reference: `scriptnode_enrichment/output/control/smoothed_parameter.md`

## Naming

- Module ID: `SmoothedStereoPan`
- Network ID: `smoothed_stereo_pan`

## Graph Plan

```text
smoothed_stereo_pan
  PanSmoother            control.smoothed_parameter
  StereoPanner           jdsp.jpanner
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Use repeated full-left and full-right jumps for timing verification.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Pan -> `PanSmoother.Value` with macro range `[-1, 1]` mapped to target `[0, 1]`; default `0`
- SmoothingTime -> `PanSmoother.SmoothingTime` matched; range `[10, 1000]` ms; default `250`
- SmoothingEnabled -> `PanSmoother.Enabled` matched; range `Off/On`; default `On`

## Defaults To Omit

- `PanSmoother.Value` default `0.0`
- `PanSmoother.SmoothingTime` default `100`
- `PanSmoother.Enabled` default `On`

## Locked Build Values

- `PanSmoother.Mode` property = `Linear Ramp`
- `PanSmoother` output -> `StereoPanner.Pan` range = `[-1, 1]`
- `StereoPanner.Rule` = `ConstantPower`
- Temporary verification mode = `Low Pass`; canonical final mode returns to `Linear Ramp`.

## Friction Comments To Weave In

- Before public Pan: bipolar UI values normalize into the smoother's 0..1 input.
- Before Mode: Linear Ramp reaches the target in the specified time; Low Pass only approaches asymptotically.
- Before Enabled: disabling smoothing passes changes immediately while retaining the same normalized mapping.

## Cosmetic Plan

- Main node: `PanSmoother`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`StereoPanner`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`PanSmoother`, `StereoPanner`]

## Open Questions

- None
