# control.branch_cable - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/control/branch_cable.md`
- Reference: `scriptnode_enrichment/output/control/branch_cable.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Selectable stereo RMS meter bus verified with three global cable destinations.

## Naming

- Module ID: `SelectableRmsMeterBus`
- Network ID: `selectable_rms_meter_bus`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - None
- Channel/routing setup verified:
  - Required channels: `default stereo`
  - Module routing: `default`
  - Master routing: `default`

## Verified Parameters

- `RmsAverage.Mode` = `LowPass`
- `RmsAverage.Frequency` = `10` range `[0.1..20000]`
- `MeterRouter.NumParameters` = `3`
- `MeterRouter.Index` range `[0..2]` stepSize `1`
- `MeterBus` range `[0..2]` stepSize `1` default `0`
- `InputMeter.Value` range `[0..1]`
- `EffectMeter.Value` range `[0..1]`
- `OutputMeter.Value` range `[0..1]`

## Verified Connections

- `RmsPeak.0` -> `MeterRouter.Value` matched: false (modulation output)
- `MeterRouter.0` -> `InputMeter.Value`
- `MeterRouter.1` -> `EffectMeter.Value`
- `MeterRouter.2` -> `OutputMeter.Value`
- `selectable_rms_meter_bus.MeterBus` -> `MeterRouter.Index` matched: true

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module SelectableRmsMeterBus --container selectable_rms_meter_bus --inject dirac --inject-param selectable_rms_meter_bus.MeterBus=0 --probe-changed-parameters --agent`
  - `hise-cli dsp trace --module SelectableRmsMeterBus --container selectable_rms_meter_bus --inject dirac --inject-param selectable_rms_meter_bus.MeterBus=1 --probe-changed-parameters --agent`
  - `hise-cli dsp trace --module SelectableRmsMeterBus --container selectable_rms_meter_bus --inject dirac --inject-param selectable_rms_meter_bus.MeterBus=2 --probe-changed-parameters --agent`
- Parameter trace evidence:
  - `MeterBus=0` routed the RMS value to `InputMeter.Value=0.0511`.
  - `MeterBus=1` routed the RMS value to `EffectMeter.Value=0.0516`.
  - `MeterBus=2` routed the RMS value to `OutputMeter.Value=0.0516`.
  - All selected values remained normalized and `outOfRange=false`.
- Signal trace commands:
  - `hise-cli dsp trace --module SelectableRmsMeterBus --container selectable_rms_meter_bus --inject dirac --probe-recursive --agent`
- Signal trace evidence:
  - Runtime status was `ok=true`. The audio path preserved stereo Dirac output. The analysis path produced non-zero squared, averaged, and rooted envelopes, then `AnalysisClear` returned silence so the analysis signal was not summed into the output.
- Trace caveats:
  - `core.peak` exports the larger left or right envelope, not an arithmetic mean. Unselected global cable outputs retain their previous snapshots.

## Locked Build Values Applied

- `RmsAverage.Mode` = `LowPass`
- `RmsAverage.Frequency` range = `[0.1, 20000]`
- `RmsAverage.Frequency` = `10`
- `MeterRouter.NumParameters` = `3`
- Global cable IDs = `InputMeter`, `EffectMeter`, `OutputMeter`

## Interface Script Setup Applied

- None

## Optimized Public Shell Commands

These shell `hise-cli` commands are intended for Phase 4 conversion to public `.hsc`. They must not include `save` or `screenshot`.

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SelectableRmsMeterBus --parent "Master Chain.FX Chain" --agent
hise-cli builder set --module SelectableRmsMeterBus --network selectable_rms_meter_bus --agent
hise-cli dsp add --module SelectableRmsMeterBus --type container.split --id MeterSplit --parent selectable_rms_meter_bus --agent
hise-cli dsp add --module SelectableRmsMeterBus --type container.chain --id AudioPath --parent MeterSplit --agent
hise-cli dsp add --module SelectableRmsMeterBus --type container.chain --id AnalysisPath --parent MeterSplit --agent
hise-cli dsp add --module SelectableRmsMeterBus --type math.square --id SignalSquare --parent AnalysisPath --agent
hise-cli dsp add --module SelectableRmsMeterBus --type filters.one_pole --id RmsAverage --parent AnalysisPath --agent
hise-cli dsp add --module SelectableRmsMeterBus --type math.sqrt --id RmsRoot --parent AnalysisPath --agent
hise-cli dsp add --module SelectableRmsMeterBus --type core.peak --id RmsPeak --parent AnalysisPath --agent
hise-cli dsp add --module SelectableRmsMeterBus --type math.clear --id AnalysisClear --parent AnalysisPath --agent
hise-cli dsp add --module SelectableRmsMeterBus --type control.branch_cable --id MeterRouter --parent selectable_rms_meter_bus --agent
hise-cli dsp add --module SelectableRmsMeterBus --type routing.global_cable --id InputMeter --parent selectable_rms_meter_bus --agent
hise-cli dsp add --module SelectableRmsMeterBus --type routing.global_cable --id EffectMeter --parent selectable_rms_meter_bus --agent
hise-cli dsp add --module SelectableRmsMeterBus --type routing.global_cable --id OutputMeter --parent selectable_rms_meter_bus --agent
hise-cli dsp set --module SelectableRmsMeterBus --node RmsAverage --param Mode --value LP --agent
hise-cli dsp set --module SelectableRmsMeterBus --node RmsAverage --param Frequency --range "0.1,20000" --agent
hise-cli dsp set --module SelectableRmsMeterBus --node RmsAverage --param Frequency --value 10 --agent
hise-cli dsp set --module SelectableRmsMeterBus --node MeterRouter --param NumParameters --value 3 --agent
hise-cli dsp set --module SelectableRmsMeterBus --node MeterRouter --param Index --range "0,2" --stepSize 1 --agent
hise-cli dsp create_parameter --module SelectableRmsMeterBus --container selectable_rms_meter_bus --id MeterBus --range "0,2" --default 0 --stepSize 1 --agent
hise-cli dsp connect --module SelectableRmsMeterBus --source RmsPeak --target MeterRouter --param Value --agent
hise-cli dsp connect --module SelectableRmsMeterBus --source-output 0 --source MeterRouter --target InputMeter --param Value --agent
hise-cli dsp connect --module SelectableRmsMeterBus --source-output 1 --source MeterRouter --target EffectMeter --param Value --agent
hise-cli dsp connect --module SelectableRmsMeterBus --source-output 2 --source MeterRouter --target OutputMeter --param Value --agent
hise-cli dsp connect --module SelectableRmsMeterBus --source selectable_rms_meter_bus --source-param MeterBus --target MeterRouter --param Index --matched --agent
hise-cli dsp set --module SelectableRmsMeterBus --node MeterRouter --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module SelectableRmsMeterBus --node RmsAverage --param NodeColour --value 0xFF6F6A91 --agent
hise-cli dsp set --module SelectableRmsMeterBus --node RmsPeak --param NodeColour --value 0xFF6F6A91 --agent
hise-cli dsp set --module SelectableRmsMeterBus --node InputMeter --param NodeColour --value 0xFF6F6A91 --agent
hise-cli dsp set --module SelectableRmsMeterBus --node EffectMeter --param NodeColour --value 0xFF6F6A91 --agent
hise-cli dsp set --module SelectableRmsMeterBus --node OutputMeter --param NodeColour --value 0xFF6F6A91 --agent
hise-cli dsp set --module SelectableRmsMeterBus --node MeterSplit --param Comment --value '\"**Meter analysis split** - The unchanged audio branch is preserved while the analysis branch is cleared after RMS export.\"' --agent
hise-cli dsp set --module SelectableRmsMeterBus --node AnalysisClear --param Comment --value '\"**Analysis disposal** - Clears the derived envelope after peak export so it cannot be summed into the audible output.\"' --agent
hise-cli dsp set --module SelectableRmsMeterBus --node MeterRouter --param Comment --value '\"**Selectable meter bus** - Index changes immediately resend the current RMS value only to the selected global cable.\"' --agent
hise-cli dsp set --module SelectableRmsMeterBus --node InputMeter --param Comment --value '\"**Input meter cable** - Unselected buses retain their last scalar snapshot.\"' --agent
hise-cli dsp set --module SelectableRmsMeterBus --node RmsPeak --param Comment --value '\"**Stereo RMS export** - Reports the larger left or right running-RMS envelope, not an arithmetic channel mean.\"' --agent
hise-cli dsp set --module SelectableRmsMeterBus --node AudioPath --param Folded --value true --agent
hise-cli dsp set --module SelectableRmsMeterBus --node SignalSquare --param Folded --value true --agent
hise-cli dsp set --module SelectableRmsMeterBus --node RmsRoot --param Folded --value true --agent
hise-cli dsp set --module SelectableRmsMeterBus --node AnalysisClear --param Folded --value true --agent
```

## Pipeline-Only Commands

These commands are not included in public `.hsc`.

```bash
hise-cli dsp status --module SelectableRmsMeterBus --agent
hise-cli dsp trace --module SelectableRmsMeterBus --container selectable_rms_meter_bus --inject dirac --probe-recursive --agent
hise-cli dsp save --module SelectableRmsMeterBus --agent
hise-cli dsp screenshot --module SelectableRmsMeterBus --scale 200% --output "scriptnode_enrichment/hsc/output/control/branch_cable.png" --agent
```

## Comments To Preserve In HSC

- Before `AnalysisClear`: clear the derived envelope after peak export so the analysis branch contributes silence to the split sum.
- Before `MeterRouter`: Index changes immediately resend the current RMS value only to the selected cable.
- Before global cables: unselected buses retain their last snapshot and scalar cable values are clamped to 0..1.
- Before meter description: `core.peak` reports the larger channel envelope, not a cross-channel arithmetic mean.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase2/control/branch_cable.md`: documented the live low-frequency range override and raw peak connection.
- General rules promoted:
  - Analysis branches must clear their derived signal after control export when used inside a split container.
- Local-only findings:
  - Global cable values are scalar and normalized; inactive destinations retain their last snapshots.

## Cosmetics Applied

- Main node: `MeterRouter` colour `0xFF2F80ED`
- Support nodes: [`RmsAverage`, `RmsPeak`, `InputMeter`, `EffectMeter`, `OutputMeter`] colour `0xFF6F6A91`
- Folded nodes: [`AudioPath`, `SignalSquare`, `RmsRoot`, `AnalysisClear`]
- ShowParameters containers: []
- Visible target nodes: [`MeterRouter`, `RmsPeak`, `InputMeter`, `EffectMeter`, `OutputMeter`]

## Defaults Omitted

- `MeterRouter.Index` default `0`
- `MeterRouter.Value` default `0.0`
- `AnalysisClear.Value` default `0.0`

## Open Issues

- None
