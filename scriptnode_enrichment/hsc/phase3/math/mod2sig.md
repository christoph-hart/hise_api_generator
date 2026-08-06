# math.mod2sig - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/mod2sig.md`
- Reference: `scriptnode_enrichment/output/math/mod2sig.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully for the known unipolar-to-bipolar conversion.

## Naming

- Module ID: `UnipolarToBipolar`
- Network ID: `unipolar_to_bipolar`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.25`

## Verified Connections

- None; fixed range conversion.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id UnipolarToBipolar --agent
hise-cli builder set --module UnipolarToBipolar --network unipolar_to_bipolar --agent
hise-cli dsp add --module UnipolarToBipolar --type math.add --id SeedValue --agent
hise-cli dsp set --module UnipolarToBipolar --node SeedValue --param Value --value 0.25 --agent
hise-cli dsp add --module UnipolarToBipolar --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module UnipolarToBipolar --type math.mod2sig --id RangeConverter --agent
hise-cli dsp add --module UnipolarToBipolar --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module UnipolarToBipolar --type math.clear --id SignalClear --agent
```

## Comments To Preserve In HSC

- Keep the seed inside 0..1 so the example stays about modulation conversion.
- `math.mod2sig` maps 0..1 into -1..1.

## Cosmetics

- Main node: `RangeConverter`, colour `0xFF2F80ED`
- Supporting nodes: `SeedValue`, `InputSpecs`, `OutputSpecs`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `InputSpecs`, `RangeConverter`, `OutputSpecs`
