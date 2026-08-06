# math.tanh - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/tanh.md`
- Reference: `scriptnode_enrichment/output/math/tanh.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with the public saturation drive.

## Naming

- Module ID: `SoftSaturationShaper`
- Network ID: `soft_saturation_shaper`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SlowRamp.PeriodTime` = `1000`
- `SoftClipper.Value` = `0.75`, range `0.4..1`
- `Drive` = `0.75`, range `0.4..1`

## Verified Connections

- `Drive` -> `SoftClipper.Value`, matched: true

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SoftSaturationShaper --agent
hise-cli builder set --module SoftSaturationShaper --network soft_saturation_shaper --agent
hise-cli dsp add --module SoftSaturationShaper --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module SoftSaturationShaper --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module SoftSaturationShaper --type math.tanh --id SoftClipper --agent
hise-cli dsp set --module SoftSaturationShaper --node SoftClipper --param Value --range "0.4,1" --agent
hise-cli dsp set --module SoftSaturationShaper --node SoftClipper --param Value --value 0.75 --agent
hise-cli dsp add --module SoftSaturationShaper --type core.peak --id OutputPeak --agent
hise-cli dsp add --module SoftSaturationShaper --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module SoftSaturationShaper --container soft_saturation_shaper --id Drive --range "0.4,1" --default 0.75 --agent
hise-cli dsp connect --module SoftSaturationShaper --source soft_saturation_shaper --source-param Drive --target SoftClipper --param Value --matched --agent
```

## Comments To Preserve In HSC

- Use enough drive that the rounded tanh curve is visibly different from a straight ramp.
- The node demonstrates soft saturation rather than a complete distortion effect.

## Cosmetics

- Main node: `SoftClipper`, colour `0xFF2F80ED`
- Supporting nodes: `SlowRamp`, `OutputPeak`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SlowRamp`, `SoftClipper`, `OutputPeak`
