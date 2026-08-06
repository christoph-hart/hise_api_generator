# math.abs - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/abs.md`
- Reference: `scriptnode_enrichment/output/math/abs.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully for the bipolar ramp and full-wave fold.

## Naming

- Module ID: `FoldedTriangleShaper`
- Network ID: `folded_triangle_shaper`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SlowRamp.PeriodTime` = `1000`
- `BipolarOffset.Value` = `-0.5`
- `BipolarScale.Value` = `2.0`

## Verified Connections

- None; this example has no public controls.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id FoldedTriangleShaper --agent
hise-cli builder set --module FoldedTriangleShaper --network folded_triangle_shaper --agent
hise-cli dsp add --module FoldedTriangleShaper --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module FoldedTriangleShaper --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module FoldedTriangleShaper --type math.add --id BipolarOffset --agent
hise-cli dsp set --module FoldedTriangleShaper --node BipolarOffset --param Value --range "-1,1" --agent
hise-cli dsp set --module FoldedTriangleShaper --node BipolarOffset --param Value --value -0.5 --agent
hise-cli dsp add --module FoldedTriangleShaper --type math.mul --id BipolarScale --agent
hise-cli dsp set --module FoldedTriangleShaper --node BipolarScale --param Value --range "0,2" --agent
hise-cli dsp set --module FoldedTriangleShaper --node BipolarScale --param Value --value 2 --agent
hise-cli dsp add --module FoldedTriangleShaper --type math.abs --id FoldShape --agent
hise-cli dsp add --module FoldedTriangleShaper --type core.peak --id OutputPeak --agent
hise-cli dsp add --module FoldedTriangleShaper --type math.clear --id SignalClear --agent
```

## Comments To Preserve In HSC

- Shift and scale the 0..1 ramp first so `math.abs` receives a bipolar signal.
- The absolute-value fold is continuous full-wave rectification, unlike `math.rect`.
- Clear the artificial ramp after the peak display.

## Cosmetics

- Main node: `FoldShape`, colour `0xFF2F80ED`
- Supporting nodes: `BipolarOffset`, `BipolarScale`, `OutputPeak`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SlowRamp`, `BipolarOffset`, `BipolarScale`, `FoldShape`, `OutputPeak`
