# math.inv - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/inv.md`
- Reference: `scriptnode_enrichment/output/math/inv.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully for the static polarity-flip test.

## Naming

- Module ID: `SignalPolarityInverter`
- Network ID: `signal_polarity_inverter`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.6`
- `InvertPolarity.Value` remains at default `0.0`

## Verified Connections

- None; `math.inv` has no meaningful public control.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SignalPolarityInverter --agent
hise-cli builder set --module SignalPolarityInverter --network signal_polarity_inverter --agent
hise-cli dsp add --module SignalPolarityInverter --type math.add --id SeedValue --agent
hise-cli dsp set --module SignalPolarityInverter --node SeedValue --param Value --value 0.6 --agent
hise-cli dsp add --module SignalPolarityInverter --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module SignalPolarityInverter --type math.inv --id InvertPolarity --agent
hise-cli dsp add --module SignalPolarityInverter --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module SignalPolarityInverter --type math.clear --id SignalClear --agent
```

## Comments To Preserve In HSC

- Seed a non-zero signal so the polarity flip is visible in the analyser.
- `math.inv` negates bipolar audio; it is not the unipolar `1 - x` transform.

## Cosmetics

- Main node: `InvertPolarity`, colour `0xFF2F80ED`
- Supporting nodes: `SeedValue`, `InputSpecs`, `OutputSpecs`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `InputSpecs`, `InvertPolarity`, `OutputSpecs`
