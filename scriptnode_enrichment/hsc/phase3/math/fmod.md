# math.fmod - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/fmod.md`
- Reference: `scriptnode_enrichment/output/math/fmod.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with the shared positive control.

## Naming

- Module ID: `WrappedRampRepeater`
- Network ID: `wrapped_ramp_repeater`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SlowRamp.PeriodTime` = `1000`
- `WrapStage.Value` = `1.0`, range `0.2..1`
- `NormalizeStage.Value` = `1.0`, range `0.2..1`
- `WrapAmount` = `1.0`, range `0.2..1`

## Verified Connections

- `WrapAmount` -> `WrapStage.Value` and `NormalizeStage.Value`, matched: true

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id WrappedRampRepeater --agent
hise-cli builder set --module WrappedRampRepeater --network wrapped_ramp_repeater --agent
hise-cli dsp add --module WrappedRampRepeater --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module WrappedRampRepeater --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module WrappedRampRepeater --type math.fmod --id WrapStage --agent
hise-cli dsp set --module WrappedRampRepeater --node WrapStage --param Value --range "0.2,1" --agent
hise-cli dsp set --module WrappedRampRepeater --node WrapStage --param Value --value 1 --agent
hise-cli dsp add --module WrappedRampRepeater --type math.div --id NormalizeStage --agent
hise-cli dsp set --module WrappedRampRepeater --node NormalizeStage --param Value --range "0.2,1" --agent
hise-cli dsp set --module WrappedRampRepeater --node NormalizeStage --param Value --value 1 --agent
hise-cli dsp add --module WrappedRampRepeater --type core.peak --id OutputPeak --agent
hise-cli dsp add --module WrappedRampRepeater --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module WrappedRampRepeater --container wrapped_ramp_repeater --id WrapAmount --range "0.2,1" --default 1 --agent
hise-cli dsp connect --module WrappedRampRepeater --source wrapped_ramp_repeater --source-param WrapAmount --target WrapStage --param Value --matched --agent
hise-cli dsp connect --module WrappedRampRepeater --source wrapped_ramp_repeater --source-param WrapAmount --target NormalizeStage --param Value --matched --agent
```

## Comments To Preserve In HSC

- Use one positive control for wrapping and renormalization.
- Keep the range away from zero because the zero guard changes the demonstration.

## Cosmetics

- Main node: `WrapStage`, colour `0xFF2F80ED`
- Supporting nodes: `NormalizeStage`, `OutputPeak`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SlowRamp`, `WrapStage`, `NormalizeStage`, `OutputPeak`
