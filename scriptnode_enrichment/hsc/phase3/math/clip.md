# math.clip - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/clip.md`
- Reference: `scriptnode_enrichment/output/math/clip.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with the visible hard-clipping plateau.

## Naming

- Module ID: `HardClipShaper`
- Network ID: `hard_clip_shaper`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SlowRamp.PeriodTime` = `1000`
- `RampOffset.Value` = `0.0`
- `HardClipper.Value` = `0.35`, range `0.1..0.6`
- `ClipLimit` = `0.35`, range `0.1..0.6`

## Verified Connections

- `ClipLimit` -> `HardClipper.Value`, matched: true

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id HardClipShaper --agent
hise-cli builder set --module HardClipShaper --network hard_clip_shaper --agent
hise-cli dsp add --module HardClipShaper --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module HardClipShaper --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module HardClipShaper --type math.add --id RampOffset --agent
hise-cli dsp set --module HardClipShaper --node RampOffset --param Value --value 0 --agent
hise-cli dsp add --module HardClipShaper --type math.clip --id HardClipper --agent
hise-cli dsp set --module HardClipShaper --node HardClipper --param Value --range "0.1,0.6" --agent
hise-cli dsp set --module HardClipShaper --node HardClipper --param Value --value 0.35 --agent
hise-cli dsp add --module HardClipShaper --type core.peak --id OutputPeak --agent
hise-cli dsp add --module HardClipShaper --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module HardClipShaper --container hard_clip_shaper --id ClipLimit --range "0.1,0.6" --default 0.35 --agent
hise-cli dsp connect --module HardClipShaper --source hard_clip_shaper --source-param ClipLimit --target HardClipper --param Value --matched --agent
```

## Comments To Preserve In HSC

- Use a low clip limit so the peak display shows a flat plateau.
- `math.clip` applies symmetric hard clipping around zero.

## Cosmetics

- Main node: `HardClipper`, colour `0xFF2F80ED`
- Supporting nodes: `SlowRamp`, `RampOffset`, `OutputPeak`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SlowRamp`, `HardClipper`, `OutputPeak`
