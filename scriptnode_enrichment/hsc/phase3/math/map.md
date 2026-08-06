# math.map - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/map.md`
- Reference: `scriptnode_enrichment/output/math/map.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with the narrowed range controls.

## Naming

- Module ID: `ClampedRangeMapper`
- Network ID: `clamped_range_mapper`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.8`
- `RangeMapper.InputStart` = `0.0`
- `RangeMapper.InputEnd` = `0.6`
- `RangeMapper.OutputStart` = `0.2`
- `RangeMapper.OutputEnd` = `0.9`
- `InputEnd` = `0.6`, `OutputStart` = `0.2`, `OutputEnd` = `0.9`

## Verified Connections

- `InputEnd` -> `RangeMapper.InputEnd`, matched: true
- `OutputStart` -> `RangeMapper.OutputStart`, matched: true
- `OutputEnd` -> `RangeMapper.OutputEnd`, matched: true

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ClampedRangeMapper --agent
hise-cli builder set --module ClampedRangeMapper --network clamped_range_mapper --agent
hise-cli dsp add --module ClampedRangeMapper --type math.add --id SeedValue --agent
hise-cli dsp set --module ClampedRangeMapper --node SeedValue --param Value --value 0.8 --agent
hise-cli dsp add --module ClampedRangeMapper --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ClampedRangeMapper --type math.map --id RangeMapper --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param InputEnd --range "0.4,0.8" --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param InputEnd --value 0.6 --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param OutputStart --range "0,0.3" --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param OutputStart --value 0.2 --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param OutputEnd --range "0.6,1" --agent
hise-cli dsp set --module ClampedRangeMapper --node RangeMapper --param OutputEnd --value 0.9 --agent
hise-cli dsp add --module ClampedRangeMapper --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ClampedRangeMapper --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module ClampedRangeMapper --container clamped_range_mapper --id InputEnd --range "0.4,0.8" --default 0.6 --agent
hise-cli dsp create_parameter --module ClampedRangeMapper --container clamped_range_mapper --id OutputStart --range "0,0.3" --default 0.2 --agent
hise-cli dsp create_parameter --module ClampedRangeMapper --container clamped_range_mapper --id OutputEnd --range "0.6,1" --default 0.9 --agent
hise-cli dsp connect --module ClampedRangeMapper --source clamped_range_mapper --source-param InputEnd --target RangeMapper --param InputEnd --matched --agent
hise-cli dsp connect --module ClampedRangeMapper --source clamped_range_mapper --source-param OutputStart --target RangeMapper --param OutputStart --matched --agent
hise-cli dsp connect --module ClampedRangeMapper --source clamped_range_mapper --source-param OutputEnd --target RangeMapper --param OutputEnd --matched --agent
```

## Comments To Preserve In HSC

- Keep the input and output bounds narrow so the clamping behavior is easy to read.
- The seeded value is deliberately near/outside the input edge.

## Cosmetics

- Main node: `RangeMapper`, colour `0xFF2F80ED`
- Supporting nodes: `SeedValue`, `InputSpecs`, `OutputSpecs`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `InputSpecs`, `RangeMapper`, `OutputSpecs`
