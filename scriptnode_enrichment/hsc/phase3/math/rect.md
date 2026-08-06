# math.rect - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/rect.md`
- Reference: `scriptnode_enrichment/output/math/rect.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully for the fixed 0.5 threshold gate.

## Naming

- Module ID: `ThresholdRectifier`
- Network ID: `threshold_rectifier`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.25`
- `BinaryGate.Value` remains at default `0.0`; threshold is fixed at `0.5`

## Verified Connections

- None; fixed threshold transform.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ThresholdRectifier --agent
hise-cli builder set --module ThresholdRectifier --network threshold_rectifier --agent
hise-cli dsp add --module ThresholdRectifier --type math.add --id SeedValue --agent
hise-cli dsp set --module ThresholdRectifier --node SeedValue --param Value --value 0.25 --agent
hise-cli dsp add --module ThresholdRectifier --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ThresholdRectifier --type math.rect --id BinaryGate --agent
hise-cli dsp add --module ThresholdRectifier --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ThresholdRectifier --type math.clear --id SignalClear --agent
```

## Comments To Preserve In HSC

- `math.rect` uses a hardcoded 0.5 threshold and produces binary output.
- The threshold is not user-adjustable.

## Cosmetics

- Main node: `BinaryGate`, colour `0xFF2F80ED`
- Supporting nodes: `SeedValue`, `InputSpecs`, `OutputSpecs`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `InputSpecs`, `BinaryGate`, `OutputSpecs`
