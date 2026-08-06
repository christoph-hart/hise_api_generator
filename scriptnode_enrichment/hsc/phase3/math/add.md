# math.add - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/math/add.md`
- Reference: `scriptnode_enrichment/output/math/add.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully with the public macro and analyser topology.

## Naming

- Module ID: `DcOffsetAdder`
- Network ID: `dc_offset_adder`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: None
- Channel/routing setup verified: default stereo routing

## Verified Parameters

- `SeedValue.Value` = `0.2`
- `OffsetAdder.Value` = `0.3`, range `0..0.5`
- `DcOffset` = `0.3`, range `0..0.5`

## Verified Connections

- `DcOffset` -> `OffsetAdder.Value`, matched: true

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DcOffsetAdder --agent
hise-cli builder set --module DcOffsetAdder --network dc_offset_adder --agent
hise-cli dsp add --module DcOffsetAdder --type math.add --id SeedValue --agent
hise-cli dsp set --module DcOffsetAdder --node SeedValue --param Value --value 0.2 --agent
hise-cli dsp add --module DcOffsetAdder --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module DcOffsetAdder --type math.add --id OffsetAdder --agent
hise-cli dsp set --module DcOffsetAdder --node OffsetAdder --param Value --range "0,0.5" --agent
hise-cli dsp set --module DcOffsetAdder --node OffsetAdder --param Value --value 0.3 --agent
hise-cli dsp add --module DcOffsetAdder --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module DcOffsetAdder --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module DcOffsetAdder --container dc_offset_adder --id DcOffset --range "0,0.5" --default 0.3 --agent
hise-cli dsp connect --module DcOffsetAdder --source dc_offset_adder --source-param DcOffset --target OffsetAdder --param Value --matched --agent
```

## Comments To Preserve In HSC

- Seed a non-zero value before the input analyser so the offset is visible.
- `math.add` applies raw linear DC offset, not decibel gain.
- `math.clear` prevents the artificial test signal from reaching the output.

## Cosmetics

- Main node: `OffsetAdder`, colour `0xFF2F80ED`
- Supporting nodes: `SeedValue`, `InputSpecs`, `OutputSpecs`, colour `0xFF6F8FAF`
- Folded nodes: `SignalClear`
- Visible nodes: `SeedValue`, `InputSpecs`, `OffsetAdder`, `OutputSpecs`
