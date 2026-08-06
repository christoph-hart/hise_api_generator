# math.div - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/div.md`
- Reference: `scriptnode_enrichment/output/math/div.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with the shared positive control.

## Naming

- Module ID: `WrappedRampNormalizer`
- Network ID: `wrapped_ramp_normalizer`

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

- `WrapAmount` -> `WrapStage.Value`, matched: true
- `WrapAmount` -> `NormalizeStage.Value`, matched: true

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id WrappedRampNormalizer --agent
hise-cli builder set --module WrappedRampNormalizer --network wrapped_ramp_normalizer --agent
hise-cli dsp add --module WrappedRampNormalizer --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module WrappedRampNormalizer --node SlowRamp --param PeriodTime --range "250,4000" --stepSize 1 --agent
hise-cli dsp set --module WrappedRampNormalizer --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module WrappedRampNormalizer --type math.fmod --id WrapStage --agent
hise-cli dsp set --module WrappedRampNormalizer --node WrapStage --param Value --range "0.2,1" --agent
hise-cli dsp set --module WrappedRampNormalizer --node WrapStage --param Value --value 1 --agent
hise-cli dsp add --module WrappedRampNormalizer --type math.div --id NormalizeStage --agent
hise-cli dsp set --module WrappedRampNormalizer --node NormalizeStage --param Value --range "0.2,1" --agent
hise-cli dsp set --module WrappedRampNormalizer --node NormalizeStage --param Value --value 1 --agent
hise-cli dsp add --module WrappedRampNormalizer --type core.peak --id OutputPeak --agent
hise-cli dsp add --module WrappedRampNormalizer --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module WrappedRampNormalizer --container wrapped_ramp_normalizer --id WrapAmount --range "0.2,1" --default 1 --agent
hise-cli dsp connect --module WrappedRampNormalizer --source wrapped_ramp_normalizer --source-param WrapAmount --target WrapStage --param Value --matched --agent
hise-cli dsp connect --module WrappedRampNormalizer --source wrapped_ramp_normalizer --source-param WrapAmount --target NormalizeStage --param Value --matched --agent
```

## Comments To Preserve In HSC

- Keep the divisor positive; zero and negative values produce silence.
- Drive the wrap and normalization stages from the same narrowed macro so they remain aligned.

## Cosmetics

- Main node: `NormalizeStage`, colour `0xFF2F80ED`
- Supporting nodes: `WrapStage`, `OutputPeak`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SlowRamp`, `WrapStage`, `NormalizeStage`, `OutputPeak`
