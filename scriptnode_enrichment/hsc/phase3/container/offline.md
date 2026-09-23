# container.offline - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/offline.md`
- Reference: `scriptnode_enrichment/output/container/offline.md`

## Status

- Built in HISE: true
- User approved: true

## Naming

- Module ID: `EventDrivenControlPipeline`
- Network ID: `event_driven_control_pipeline`

## Builder Setup Applied

- Host context: `Script FX`

## Final Topology

```text
event_driven_control_pipeline
  OfflineControls
    AmountCurve
    GainRange
  AudioGain
```

## Verified Configuration

- Root `Amount`: range `0..1`, default `0.5`
- `AmountCurve.Code` = `input * input`
- `GainRange.Multiply` = `0.8`
- `GainRange.Add` = `0.2`
- `AudioGain.Value`: range `0..1`, step size `0`
- Root `Amount` -> `AmountCurve.Value`
- `AmountCurve.0` -> `GainRange.Value`
- `GainRange.0` -> `AudioGain.Value`
- Network compilation enabled for the SNEX cable expression

## Trace Validation

Using a `0.5` DC input:

- Amount `0`: gain `0.2`, output `0.1`
- Amount `0.5`: squared value `0.25`, gain `0.4`, output `0.2`
- Amount `1`: gain `1.0`, output `0.5`

The offline wrapper passed audio unchanged. Its control nodes propagated parameter changes synchronously to the sample-processing node outside the wrapper.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id EventDrivenControlPipeline --agent
hise-cli builder set --module EventDrivenControlPipeline --network event_driven_control_pipeline --agent

# Children receive preparation and reset, but no realtime process, frame, or MIDI callbacks.
hise-cli dsp add --module EventDrivenControlPipeline --type container.offline --id OfflineControls --agent
hise-cli dsp add --module EventDrivenControlPipeline --type control.cable_expr --id AmountCurve --parent OfflineControls --agent
hise-cli dsp add --module EventDrivenControlPipeline --type control.pma --id GainRange --parent OfflineControls --agent
# Keep the sample processor outside the offline container.
hise-cli dsp add --module EventDrivenControlPipeline --type math.mul --id AudioGain --agent

hise-cli dsp set --module EventDrivenControlPipeline --node AmountCurve --param Code --value '"input * input"' --agent
hise-cli dsp set --module EventDrivenControlPipeline --node GainRange --param Multiply --value 0.8 --agent
hise-cli dsp set --module EventDrivenControlPipeline --node GainRange --param Add --value 0.2 --agent
hise-cli dsp set --module EventDrivenControlPipeline --node AudioGain --param Value --range "0,1" --stepSize 0 --agent

hise-cli dsp create_parameter --module EventDrivenControlPipeline --container event_driven_control_pipeline --id Amount --range "0,1" --default 0.5 --agent
hise-cli dsp connect --module EventDrivenControlPipeline --source event_driven_control_pipeline --source-param Amount --target AmountCurve --param Value --matched --agent
hise-cli dsp connect --module EventDrivenControlPipeline --source AmountCurve --target GainRange --param Value --agent
hise-cli dsp connect --module EventDrivenControlPipeline --source GainRange --target AudioGain --param Value --agent

# cable_expr requires a compile-enabled network. Apply and verify HISE's status autofix if needed.
hise-cli dsp status --module EventDrivenControlPipeline --autofix --agent
hise-cli dsp status --module EventDrivenControlPipeline --agent

hise-cli dsp set --module EventDrivenControlPipeline --node OfflineControls --param NodeColour --value 0xFF7F8C8D --agent
hise-cli dsp set --module EventDrivenControlPipeline --node OfflineControls --param Comment --value '"Children are prepared and reset but receive no realtime process, frame, or MIDI callbacks. Audio passes through unchanged."' --agent
hise-cli dsp set --module EventDrivenControlPipeline --node AmountCurve --param NodeColour --value 0xFF687273 --agent
hise-cli dsp set --module EventDrivenControlPipeline --node AmountCurve --param Comment --value '"SNEX squares Amount. This cable node propagates parameter changes synchronously without realtime processing."' --agent
hise-cli dsp set --module EventDrivenControlPipeline --node GainRange --param NodeColour --value 0xFF687273 --agent
hise-cli dsp set --module EventDrivenControlPipeline --node GainRange --param Comment --value '"Maps the squared control to 0.2..1.0 and immediately forwards it to AudioGain."' --agent
hise-cli dsp set --module EventDrivenControlPipeline --node AudioGain --param NodeColour --value 0xFF687273 --agent
hise-cli dsp set --module EventDrivenControlPipeline --node AudioGain --param Comment --value '"The sample processor must remain outside OfflineControls; only its parameter is driven by the offline cable chain."' --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp trace --module EventDrivenControlPipeline --container event_driven_control_pipeline --inject dc --gain 0.5 --inject-param event_driven_control_pipeline.Amount=0 --probe-recursive --probe-changed-parameters --trace-compact --agent
hise-cli dsp trace --module EventDrivenControlPipeline --container event_driven_control_pipeline --inject dc --gain 0.5 --inject-param event_driven_control_pipeline.Amount=0.5 --probe-recursive --probe-changed-parameters --trace-compact --agent
hise-cli dsp trace --module EventDrivenControlPipeline --container event_driven_control_pipeline --inject dc --gain 0.5 --inject-param event_driven_control_pipeline.Amount=1 --probe-recursive --probe-changed-parameters --trace-compact --agent
hise-cli dsp save --module EventDrivenControlPipeline --agent
hise-cli dsp screenshot --module EventDrivenControlPipeline --scale 200% --output "scriptnode_enrichment/hsc/output/container/offline.png" --agent
```

## Open Issues

- None.
