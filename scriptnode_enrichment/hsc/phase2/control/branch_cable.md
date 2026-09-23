# control.branch_cable - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/control/branch_cable.md`
- Reference: `scriptnode_enrichment/output/control/branch_cable.md`

## Naming

- Module ID: `SelectableRmsMeterBus`
- Network ID: `selectable_rms_meter_bus`

## Graph Plan

```text
selectable_rms_meter_bus
  MeterSplit             container.split
    AudioPath            container.chain
    AnalysisPath         container.chain
      SignalSquare       math.square
      RmsAverage         filters.one_pole
      RmsRoot            math.sqrt
      RmsPeak            core.peak
      AnalysisClear      math.clear
  MeterRouter            control.branch_cable
  InputMeter             routing.global_cable
  EffectMeter            routing.global_cable
  OutputMeter            routing.global_cable
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - None
- Channel/routing setup:
  - Required channels: default stereo
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [analysis branch explicitly cleared before split sum]

## Public Parameters

- MeterBus -> `MeterRouter.Index` matched
- Target range before connection: `[0, 2]`, step `1`
- Macro range: `[0, 2]`, step `1`, labels `Input, Effect, Output`
- Default: `0`

## Defaults To Omit

- `MeterRouter.Index` default `0`
- `MeterRouter.Value` default `0.0`
- `AnalysisClear.Value` default `0.0`

## Locked Build Values

- `RmsAverage.Mode` = `LowPass`
- `RmsAverage.Frequency` range = `[0.1, 20000]`
- `RmsAverage.Frequency` = `10`
- `MeterRouter.NumParameters` property = `3`
- `RmsPeak` output -> `MeterRouter.Value` raw connection over `[0, 1]`
- `MeterRouter` output 0 -> `InputMeter.Value`
- `MeterRouter` output 1 -> `EffectMeter.Value`
- `MeterRouter` output 2 -> `OutputMeter.Value`
- Global cable IDs = `InputMeter`, `EffectMeter`, `OutputMeter`

## Friction Comments To Weave In

- Before `AnalysisClear`: clear the derived envelope after peak export so the analysis branch contributes silence to the split sum.
- Before `MeterRouter`: Index changes immediately resend the current RMS value only to the selected output.
- Before global cables: unselected buses retain their last snapshot and scalar cable values are clamped to 0..1.
- Before meter description: core.peak reports the larger channel envelope, not a cross-channel arithmetic mean.

## Cosmetic Plan

- Main node: `MeterRouter`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`RmsAverage`, `RmsPeak`, `InputMeter`, `EffectMeter`, `OutputMeter`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`AudioPath`, `SignalSquare`, `RmsRoot`, `AnalysisClear`]
- Nodes that must stay visible: [`MeterRouter`, `RmsPeak`, `InputMeter`, `EffectMeter`, `OutputMeter`]

## Open Questions

- None
