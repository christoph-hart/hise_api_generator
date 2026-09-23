# container.offline - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/offline.md`
- Reference: `scriptnode_enrichment/output/container/offline.md`

## Naming

- Module ID: `EventDrivenControlPipeline`
- Network ID: `event_driven_control_pipeline`

## Graph Plan

```text
event_driven_control_pipeline
  OfflineControls        container.offline
    AmountCurve          control.cable_expr
    GainRange            control.pma
  AudioGain              math.mul
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Enable compilation because the cable expression uses SNEX.
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: []

## Public Parameters

- Amount -> `AmountCurve.Value` matched
- Target range before connection: `[0, 1]`
- Macro range: `[0, 1]`
- Default: `0.5`

## Defaults To Omit

- `AmountCurve.Value` default `0.0`
- `GainRange.Value` default `0.0`
- `GainRange.Multiply` default `1.0`
- `GainRange.Add` default `0.0`
- `AudioGain.Value` default `1.0`

## Locked Build Values

- `AmountCurve.Code` = `input * input`
- `GainRange.Multiply` = `0.8`
- `GainRange.Add` = `0.2`
- `GainRange` output range = `[0, 1]`
- `AmountCurve` output -> `GainRange.Value` matched
- `GainRange` output -> `AudioGain.Value` matched over `[0, 1]`

## Friction Comments To Weave In

- Before `OfflineControls`: children are prepared and reset but receive no realtime process, frame, or MIDI callbacks.
- Before the cable chain: this works because control nodes propagate synchronous parameter changes without realtime processing.
- Before `AudioGain`: keep the sample processor outside the offline container; audio passes through the wrapper unchanged.

## Cosmetic Plan

- Main node: `OfflineControls`
- Accent colour: `0xFF7F8C8D`
- Supporting relevant nodes: [`AmountCurve`, `GainRange`, `AudioGain`]
- Supporting colour: `0xFF687273`
- Folded nodes: []
- Nodes that must stay visible: [`OfflineControls`, `AmountCurve`, `GainRange`, `AudioGain`]

## Open Questions

- None
