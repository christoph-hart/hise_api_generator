# fx.sampleandhold - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/fx/sampleandhold.md`
- Reference: `scriptnode_enrichment/output/fx/sampleandhold.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully in a ScriptFX.

## Naming

- Module ID: `SteppedNoiseTexture`
- Network ID: `stepped_noise_texture`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing.

## Verified Parameters

- `NoiseSource.Mode` = `4` (noise)
- `NoiseSource.Gain` = `0.25`
- `StepHolder.Counter` = `16`, range `[2, 64]`
- `TextureTrim.Gain` = `-12`

## Verified Connections

- `stepped_noise_texture.Counter -> StepHolder.Counter` matched

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SteppedNoiseTexture --agent
hise-cli builder set --module SteppedNoiseTexture --network stepped_noise_texture --agent
hise-cli dsp add --module SteppedNoiseTexture --type core.oscillator --id NoiseSource --agent
hise-cli dsp set --module SteppedNoiseTexture --node NoiseSource --param Mode --value 4 --agent
hise-cli dsp set --module SteppedNoiseTexture --node NoiseSource --param Gain --value 0.25 --agent
hise-cli dsp add --module SteppedNoiseTexture --type fx.sampleandhold --id StepHolder --agent
hise-cli dsp set --module SteppedNoiseTexture --node StepHolder --param Counter --range "2,64" --agent
hise-cli dsp set --module SteppedNoiseTexture --node StepHolder --param Counter --value 16 --agent
hise-cli dsp add --module SteppedNoiseTexture --type core.gain --id TextureTrim --agent
hise-cli dsp set --module SteppedNoiseTexture --node TextureTrim --param Gain --value -12 --agent
hise-cli dsp create_parameter --module SteppedNoiseTexture --container stepped_noise_texture --id Counter --range "2,64" --default 16 --agent
hise-cli dsp connect --module SteppedNoiseTexture --source stepped_noise_texture --source-param Counter --target StepHolder --param Counter --matched --agent
```

## Key rules

- `Counter` is the number of samples held per captured value. Keep the public range above `1` for audible decimation.
- Random noise makes exact sample-value assertions inappropriate; validate topology and parameter propagation.
