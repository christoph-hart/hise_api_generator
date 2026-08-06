# math.sub - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/sub.md`
- Reference: `scriptnode_enrichment/output/math/sub.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with the public macro and analyser topology.

## Naming

- Module ID: `DcSubtractor`
- Network ID: `dc_subtractor`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.8`
- `OffsetSubtractor.Value` = `0.2`, range `0..0.5`
- `Offset` = `0.2`, range `0..0.5`

## Verified Connections

- `Offset` -> `OffsetSubtractor.Value`, matched: true

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DcSubtractor --agent
hise-cli builder set --module DcSubtractor --network dc_subtractor --agent
hise-cli dsp add --module DcSubtractor --type math.add --id SeedValue --agent
hise-cli dsp set --module DcSubtractor --node SeedValue --param Value --value 0.8 --agent
hise-cli dsp add --module DcSubtractor --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module DcSubtractor --type math.sub --id OffsetSubtractor --agent
hise-cli dsp set --module DcSubtractor --node OffsetSubtractor --param Value --range "0,0.5" --agent
hise-cli dsp set --module DcSubtractor --node OffsetSubtractor --param Value --value 0.2 --agent
hise-cli dsp add --module DcSubtractor --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module DcSubtractor --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module DcSubtractor --container dc_subtractor --id Offset --range "0,0.5" --default 0.2 --agent
hise-cli dsp connect --module DcSubtractor --source dc_subtractor --source-param Offset --target OffsetSubtractor --param Value --matched --agent
```

## Comments To Preserve In HSC

- Seed a non-zero value before the input analyser so subtraction is visible.
- `math.sub` removes a raw scalar offset from every sample.
- `math.clear` prevents the artificial test signal from reaching the output.

## Cosmetics

- Main node: `OffsetSubtractor`, colour `0xFF2F80ED`
- Supporting nodes: `SeedValue`, `InputSpecs`, `OutputSpecs`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `InputSpecs`, `OffsetSubtractor`, `OutputSpecs`
