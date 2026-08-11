# fx.haas - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/fx/haas.md`
- Reference: `scriptnode_enrichment/output/fx/haas.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully in a `PolyScriptFX` hosted inside a `SineSynth` voice FX chain.

## Naming

- Module ID: `VoiceHaasScatter`
- Network ID: `voice_haas_scatter`

## Builder Setup Applied

- Host context: `PolyScriptFX`
- Additional builder steps applied: created a minimal `SineSynth` named `VoiceSource`, then added `VoiceHaasScatter` to `VoiceSource`'s `FX Chain`
- Channel/routing setup verified: default stereo routing on parent synth and polyphonic FX

## Verified Parameters

- `NoteTrigger.Value` = `1`
- `SpreadScale.Scale` = `0.65`, range `[0, 1]`
- `SpreadScale.Gamma` = `1`
- `StereoScatter.Position` left at full range `[-1, 1]`
- `voice_haas_scatter.Spread` = `0.65`, range `[0, 1]`

## Verified Connections

- `NoteTrigger.0 -> VoicePosition.Value`
- `VoicePosition.0 -> SpreadScale.Value`
- `voice_haas_scatter.Spread -> SpreadScale.Scale`
- `SpreadScale.0 -> StereoScatter.Position`

## Trace Validation

- Parameter trace commands:
  - `hise-cli dsp trace --module VoiceHaasScatter --container voice_haas_scatter --inject-param voice_haas_scatter.Spread=0.25 --probe-param SpreadScale.Scale --agent`
  - `hise-cli dsp trace --module VoiceHaasScatter --container voice_haas_scatter --inject-param NoteTrigger.Value=0.25 --probe-param VoicePosition.Value --probe-param SpreadScale.Value --probe-param StereoScatter.Position --agent`
- Parameter trace evidence:
  - Root `Spread=0.25` propagated to `SpreadScale.Scale=0.25`.
  - Trigger-path trace produced `SpreadScale.Value=0.999` and `StereoScatter.Position=0.6`, proving random output flows through the bipolar scaler into Haas Position.
  - Trace specs reported `polyphonic: true` and `processMidi: true`, confirming the graph runs in a voice-capable context.
- Signal trace commands:
  - `hise-cli dsp trace --module VoiceHaasScatter --container voice_haas_scatter --inject dirac --inject-param StereoScatter.Position=1 --probe-recursive --trace-compact --agent`
- Signal trace evidence:
  - With `StereoScatter.Position=1`, recursive trace showed `StereoScatter` output `[0, 1]` for the first traced sample, proving the left channel is delayed while the right channel passes immediately.
- Trace caveats:
  - The random value is nondeterministic, so exact Position values are not stable across runs. Validate the connection path and bounded output, not a fixed random number.

## Locked Build Values Applied

- `VoiceSource` parent module = `SineSynth`
- `VoiceHaasScatter` host module = `PolyScriptFX` under `VoiceSource` `FX Chain`
- `NoteTrigger.Value` = `1`
- `SpreadScale.Scale.range` = `[0, 1]`
- `SpreadScale.Scale` = `0.65`
- Do not narrow `StereoScatter.Position`; use `SpreadScale.Scale` to collapse or widen the random bipolar range around centre.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type SineSynth --id VoiceSource --agent
hise-cli builder add --type PolyScriptFX --id VoiceHaasScatter --parent VoiceSource --chain "FX Chain" --agent
hise-cli builder set --module VoiceHaasScatter --network voice_haas_scatter --agent
hise-cli dsp add --module VoiceHaasScatter --type control.voice_bang --id NoteTrigger --agent
hise-cli dsp set --module VoiceHaasScatter --node NoteTrigger --param Value --value 1 --agent
hise-cli dsp add --module VoiceHaasScatter --type control.random --id VoicePosition --agent
hise-cli dsp add --module VoiceHaasScatter --type control.bipolar --id SpreadScale --agent
hise-cli dsp set --module VoiceHaasScatter --node SpreadScale --param Scale --range "0,1" --agent
hise-cli dsp set --module VoiceHaasScatter --node SpreadScale --param Scale --value 0.65 --agent
hise-cli dsp add --module VoiceHaasScatter --type fx.haas --id StereoScatter --agent
hise-cli dsp create_parameter --module VoiceHaasScatter --container voice_haas_scatter --id Spread --range "0,1" --default 0.65 --agent
hise-cli dsp connect --module VoiceHaasScatter --source NoteTrigger --target VoicePosition --param Value --agent
hise-cli dsp connect --module VoiceHaasScatter --source VoicePosition --target SpreadScale --param Value --agent
hise-cli dsp connect --module VoiceHaasScatter --source voice_haas_scatter --source-param Spread --target SpreadScale --param Scale --matched --agent
hise-cli dsp connect --module VoiceHaasScatter --source SpreadScale --target StereoScatter --param Position --agent
hise-cli dsp set --module VoiceHaasScatter --node StereoScatter --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module VoiceHaasScatter --node NoteTrigger --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module VoiceHaasScatter --node VoicePosition --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module VoiceHaasScatter --node SpreadScale --param NodeColour --value 0xFF6F8FAF --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module VoiceHaasScatter --agent
hise-cli dsp screenshot --module VoiceHaasScatter --scale 200% --output "scriptnode_enrichment/hsc/output/fx/haas.png" --agent
```

## Comments To Preserve In HSC

- Before builder setup: use `PolyScriptFX`, not `ScriptFX`; Haas placement is per voice and needs note-on events.
- Before `control.bipolar`: centre and scale the random value before it reaches `fx.haas.Position`, so Spread controls width without replacing the random voice position.
- Before `fx.haas`: Haas positioning is stereo delay panning, not amplitude panning.

## Documentation Feedback

- Docs updated:
  - `scriptnode_enrichment/hsc/phase1/fx/haas.md` and `scriptnode_enrichment/hsc/phase2/fx/haas.md` now include `control.bipolar` as required support.
  - `scriptnode_enrichment/hsc/issues.md` marks the `control.bipolar.Scale` CLI parser issue fixed and verified.
- General rules promoted:
  - None
- Local-only findings:
  - `PolyScriptFX` cannot be added to the Master Chain FX chain; it must be added to a sound generator's `FX Chain`.

## Cosmetics Applied

- Main node: `StereoScatter` colour `0xFF2F80ED`
- Support nodes: [`NoteTrigger`, `VoicePosition`, `SpreadScale`] colour `0xFF6F8FAF`
- Folded nodes: []
- Visible target nodes: [`NoteTrigger`, `VoicePosition`, `SpreadScale`, `StereoScatter`]

## Defaults Omitted

- `VoicePosition.Value` default `0`
- `SpreadScale.Value` default `0`
- `SpreadScale.Gamma` default `1`
- `StereoScatter.Position` default `0`

## Open Issues

- None
