# math.pow - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/pow.md`
- Reference: `scriptnode_enrichment/output/math/pow.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with a non-negative known input.

## Naming

- Module ID: `ExponentCurveShaper`
- Network ID: `exponent_curve_shaper`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.25`
- `PowerShape.Value` remains at default `1.0` and has no processing effect

## Verified Connections

- None; `math.pow` has no meaningful public control.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ExponentCurveShaper --agent
hise-cli builder set --module ExponentCurveShaper --network exponent_curve_shaper --agent
hise-cli dsp add --module ExponentCurveShaper --type math.add --id SeedValue --agent
hise-cli dsp set --module ExponentCurveShaper --node SeedValue --param Value --value 0.25 --agent
hise-cli dsp add --module ExponentCurveShaper --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ExponentCurveShaper --type math.pow --id PowerShape --agent
hise-cli dsp add --module ExponentCurveShaper --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ExponentCurveShaper --type math.clear --id SignalClear --agent
```

## Comments To Preserve In HSC

- Keep the input non-negative because fractional exponents can produce NaN for negative values.
- This is a unipolar curve shaper rather than a bipolar audio processor.

## Cosmetics

- Main node: `PowerShape`, colour `0xFF2F80ED`
- Supporting nodes: `SeedValue`, `InputSpecs`, `OutputSpecs`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `InputSpecs`, `PowerShape`, `OutputSpecs`
