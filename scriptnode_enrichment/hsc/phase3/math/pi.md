# math.pi - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/pi.md`
- Reference: `scriptnode_enrichment/output/math/pi.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully through the modulation-range display conversion.

## Naming

- Module ID: `VisibleRadianScaler`
- Network ID: `visible_radian_scaler`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.5`
- `PiScaler.Value` = `2.0`, range `1..2`
- `CycleScale` = `2.0`, range `1..2`

## Verified Connections

- `CycleScale` -> `PiScaler.Value`, matched: true

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id VisibleRadianScaler --agent
hise-cli builder set --module VisibleRadianScaler --network visible_radian_scaler --agent
hise-cli dsp add --module VisibleRadianScaler --type math.add --id SeedValue --agent
hise-cli dsp set --module VisibleRadianScaler --node SeedValue --param Value --value 0.5 --agent
hise-cli dsp add --module VisibleRadianScaler --type math.pi --id PiScaler --agent
hise-cli dsp set --module VisibleRadianScaler --node PiScaler --param Value --range "1,2" --agent
hise-cli dsp set --module VisibleRadianScaler --node PiScaler --param Value --value 2 --agent
hise-cli dsp add --module VisibleRadianScaler --type math.sig2mod --id DisplayRange --agent
hise-cli dsp add --module VisibleRadianScaler --type core.peak --id OutputPeak --agent
hise-cli dsp add --module VisibleRadianScaler --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module VisibleRadianScaler --container visible_radian_scaler --id CycleScale --range "1,2" --default 2 --agent
hise-cli dsp connect --module VisibleRadianScaler --source visible_radian_scaler --source-param CycleScale --target PiScaler --param Value --matched --agent
```

## Comments To Preserve In HSC

- `math.pi` multiplies by PI times Value and is normally a support scaler for `math.sin`.
- Convert the scaled signal to modulation range before the peak display.

## Cosmetics

- Main node: `PiScaler`, colour `0xFF2F80ED`
- Supporting nodes: `DisplayRange`, `OutputPeak`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `PiScaler`, `DisplayRange`, `OutputPeak`
