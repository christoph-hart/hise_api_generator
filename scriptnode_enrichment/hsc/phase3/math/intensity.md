# math.intensity - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/intensity.md`
- Reference: `scriptnode_enrichment/output/math/intensity.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with the public unity-anchored depth control.

## Naming

- Module ID: `UnityAnchoredDepth`
- Network ID: `unity_anchored_depth`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SlowRamp.PeriodTime` = `1000`
- `UnityDepth.Value` = `0.4`, range `0..1`
- `Depth` = `0.4`, range `0..1`

## Verified Connections

- `Depth` -> `UnityDepth.Value`, matched: true

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id UnityAnchoredDepth --agent
hise-cli builder set --module UnityAnchoredDepth --network unity_anchored_depth --agent
hise-cli dsp add --module UnityAnchoredDepth --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module UnityAnchoredDepth --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module UnityAnchoredDepth --type math.intensity --id UnityDepth --agent
hise-cli dsp set --module UnityAnchoredDepth --node UnityDepth --param Value --range "0,1" --agent
hise-cli dsp set --module UnityAnchoredDepth --node UnityDepth --param Value --value 0.4 --agent
hise-cli dsp add --module UnityAnchoredDepth --type core.peak --id OutputPeak --agent
hise-cli dsp add --module UnityAnchoredDepth --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module UnityAnchoredDepth --container unity_anchored_depth --id Depth --range "0,1" --default 0.4 --agent
hise-cli dsp connect --module UnityAnchoredDepth --source unity_anchored_depth --source-param Depth --target UnityDepth --param Value --matched --agent
```

## Comments To Preserve In HSC

- `math.intensity` crossfades toward unity rather than multiplying around zero like `math.mul`.
- The ramp stays in the 0..1 modulation range so the anchored ceiling is visible.

## Cosmetics

- Main node: `UnityDepth`, colour `0xFF2F80ED`
- Supporting nodes: `SlowRamp`, `OutputPeak`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SlowRamp`, `UnityDepth`, `OutputPeak`
