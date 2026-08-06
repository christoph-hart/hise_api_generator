# math.mod_inv - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/mod_inv.md`
- Reference: `scriptnode_enrichment/output/math/mod_inv.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully for the known unipolar complement test.

## Naming

- Module ID: `ModulationInverter`
- Network ID: `modulation_inverter`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.25`

## Verified Connections

- None; fixed unipolar inversion.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ModulationInverter --agent
hise-cli builder set --module ModulationInverter --network modulation_inverter --agent
hise-cli dsp add --module ModulationInverter --type math.add --id SeedValue --agent
hise-cli dsp set --module ModulationInverter --node SeedValue --param Value --value 0.25 --agent
hise-cli dsp add --module ModulationInverter --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ModulationInverter --type math.mod_inv --id InvertModulation --agent
hise-cli dsp add --module ModulationInverter --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ModulationInverter --type math.clear --id SignalClear --agent
```

## Comments To Preserve In HSC

- `math.mod_inv` flips a 0..1 signal around one-half.
- Contrast this with `math.inv`, which flips bipolar polarity around zero.

## Cosmetics

- Main node: `InvertModulation`, colour `0xFF2F80ED`
- Supporting nodes: `SeedValue`, `InputSpecs`, `OutputSpecs`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `InputSpecs`, `InvertModulation`, `OutputSpecs`
