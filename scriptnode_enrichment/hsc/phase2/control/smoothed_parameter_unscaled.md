# control.smoothed_parameter_unscaled - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/smoothed_parameter_unscaled.md`
- Reference: `scriptnode_enrichment/output/control/smoothed_parameter_unscaled.md`

## Naming

- Module ID: `ClickFreeRawDelayTime`
- Network ID: `click_free_raw_delay_time`

## Graph Plan

```text
click_free_raw_delay_time
  DelayTimeSmoother      control.smoothed_parameter_unscaled
  InterpolatingDelay     jdsp.jdelay
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Use a monophonic effect context so the full delay allocation is available.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [monophonic context avoids polyphonic 30 ms limit]

## Public Parameters

- DelayTime -> `DelayTimeSmoother.Value` matched; target and macro range `[1, 500]` ms; default `120`
- SmoothingTime -> `DelayTimeSmoother.SmoothingTime` matched; range `[10, 1000]` ms; default `200`
- SmoothingEnabled -> `DelayTimeSmoother.Enabled` matched; Off/On; default `On`

## Defaults To Omit

- `DelayTimeSmoother.SmoothingTime` default `100`
- `DelayTimeSmoother.Enabled` default `On`

## Locked Build Values

- `DelayTimeSmoother.Mode` property = `Linear Ramp`
- `DelayTimeSmoother.Value` range = `[1, 500]` ms
- `DelayTimeSmoother` output -> `InterpolatingDelay.DelayTime` unscaled
- `InterpolatingDelay.Limit` = `600` ms

## Friction Comments To Weave In

- Before Value range: source and target share native milliseconds and output bypasses target conversion.
- Before Limit: allocate above the maximum public delay before processing starts.
- Before use case: control-rate smoothing suits knob jumps, not sample-accurate chorus modulation.

## Cosmetic Plan

- Main node: `DelayTimeSmoother`
- Accent colour: `0xFF8E44AD`
- Supporting relevant nodes: [`InterpolatingDelay`]
- Supporting colour: `0xFF7F6A91`
- Folded nodes: []
- Nodes that must stay visible: [`DelayTimeSmoother`, `InterpolatingDelay`]

## Open Questions

- None
