# math.square - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/square.md`
- Reference: `scriptnode_enrichment/output/math/square.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully for the fixed x*x transform.

## Naming

- Module ID: `SquaringCurveShaper`
- Network ID: `squaring_curve_shaper`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.5`
- `SquareShape.Value` remains at default `1.0` and has no processing effect

## Verified Connections

- None; `math.square` has no meaningful public control.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SquaringCurveShaper --agent
hise-cli builder set --module SquaringCurveShaper --network squaring_curve_shaper --agent
hise-cli dsp add --module SquaringCurveShaper --type math.add --id SeedValue --agent
hise-cli dsp set --module SquaringCurveShaper --node SeedValue --param Value --value 0.5 --agent
hise-cli dsp add --module SquaringCurveShaper --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module SquaringCurveShaper --type math.square --id SquareShape --agent
hise-cli dsp add --module SquaringCurveShaper --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module SquaringCurveShaper --type math.clear --id SignalClear --agent
```

## Comments To Preserve In HSC

- `math.square` computes `input * input`, forcing the result non-negative.
- Its exposed Value parameter is unused.

## Cosmetics

- Main node: `SquareShape`, colour `0xFF2F80ED`
- Supporting nodes: `SeedValue`, `InputSpecs`, `OutputSpecs`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `InputSpecs`, `SquareShape`, `OutputSpecs`
