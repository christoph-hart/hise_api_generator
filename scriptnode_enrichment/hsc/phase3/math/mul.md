# math.mul - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/mul.md`
- Reference: `scriptnode_enrichment/output/math/mul.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with the public macro and analyser topology.

## Naming

- Module ID: `ScalarGainMultiplier`
- Network ID: `scalar_gain_multiplier`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.8`
- `GainScale.Value` = `0.5`, range `0..1`
- `Multiplier` = `0.5`, range `0..1`

## Verified Connections

- `Multiplier` -> `GainScale.Value`, matched: true

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ScalarGainMultiplier --agent
hise-cli builder set --module ScalarGainMultiplier --network scalar_gain_multiplier --agent
hise-cli dsp add --module ScalarGainMultiplier --type math.add --id SeedValue --agent
hise-cli dsp set --module ScalarGainMultiplier --node SeedValue --param Value --value 0.8 --agent
hise-cli dsp add --module ScalarGainMultiplier --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ScalarGainMultiplier --type math.mul --id GainScale --agent
hise-cli dsp set --module ScalarGainMultiplier --node GainScale --param Value --range "0,1" --agent
hise-cli dsp set --module ScalarGainMultiplier --node GainScale --param Value --value 0.5 --agent
hise-cli dsp add --module ScalarGainMultiplier --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ScalarGainMultiplier --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module ScalarGainMultiplier --container scalar_gain_multiplier --id Multiplier --range "0,1" --default 0.5 --agent
hise-cli dsp connect --module ScalarGainMultiplier --source scalar_gain_multiplier --source-param Multiplier --target GainScale --param Value --matched --agent
```

## Comments To Preserve In HSC

- Seed a non-zero value before the input analyser so scaling is measurable.
- This is raw linear scaling; use `core.gain` for decibel-scaled gain control.
- `math.clear` prevents the artificial test signal from reaching the output.

## Cosmetics

- Main node: `GainScale`, colour `0xFF2F80ED`
- Supporting nodes: `SeedValue`, `InputSpecs`, `OutputSpecs`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `InputSpecs`, `GainScale`, `OutputSpecs`
