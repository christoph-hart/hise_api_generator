# math.sqrt - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/sqrt.md`
- Reference: `scriptnode_enrichment/output/math/sqrt.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with a non-negative known input.

## Naming

- Module ID: `RootCurveShaper`
- Network ID: `root_curve_shaper`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.25`
- `RootShape.Value` remains at default `1.0` and has no processing effect

## Verified Connections

- None; `math.sqrt` has no meaningful public control.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id RootCurveShaper --agent
hise-cli builder set --module RootCurveShaper --network root_curve_shaper --agent
hise-cli dsp add --module RootCurveShaper --type math.add --id SeedValue --agent
hise-cli dsp set --module RootCurveShaper --node SeedValue --param Value --value 0.25 --agent
hise-cli dsp add --module RootCurveShaper --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module RootCurveShaper --type math.sqrt --id RootShape --agent
hise-cli dsp add --module RootCurveShaper --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module RootCurveShaper --type math.clear --id SignalClear --agent
```

## Comments To Preserve In HSC

- Keep the input non-negative; negative values produce NaN.
- This is a unipolar curve shaper, not a general bipolar processor.

## Cosmetics

- Main node: `RootShape`, colour `0xFF2F80ED`
- Supporting nodes: `SeedValue`, `InputSpecs`, `OutputSpecs`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `InputSpecs`, `RootShape`, `OutputSpecs`
