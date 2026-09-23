# container.fix256_block - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/fix256_block.md`
- Reference: `scriptnode_enrichment/output/container/fix256_block.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as the 256-sample duplicate of the folded-triangle zipper-noise demonstration.

## Naming

- Module ID: `MinimalLargeBufferSplit`
- Network ID: `minimal_large_buffer_split`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Used silent input and a DC-rich additive diagnostic output.
  - Added an inspection-only specs node.
  - Folded a one-second ramp around 0.5 before exporting one value per chunk.
- Channel/routing setup verified:
  - Required channels: `default stereo; isolated mono modulation path`
  - Module routing: `default stereo`
  - Master routing: `default stereo`

## Verified Parameters

- `SourceRamp.PeriodTime` = `1000`
- `CentreRamp.Value` = `0.5`
- `StaircaseOutput.Value` range = `0..1`

## Verified Connections

- `ChunkValue.0` -> `StaircaseOutput.Value` scaled: true

## Trace Validation

- Trace command:
  - `hise-cli dsp trace --module MinimalLargeBufferSplit --container minimal_large_buffer_split --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent`
- Parameter evidence:
  - Ramp value: `0.3515`
  - Centred value: `-0.1537`
  - Folded and peak value: `0.1537`
  - Staircase output: approximately `0.1537`
- Signal evidence:
  - Root specs reported `sampleRate=48000`, `numChannels=2`, `blockSize=512`.
  - `TwoFiftySixBlocks` reported `blockSize=256`.
  - `StepControl` reported `sampleRate=6000`, `numChannels=1`, `blockSize=32`.
  - The 512-sample host callback was divided into two 256-sample child chunks.
- Trace caveats:
  - Values differ slightly across snapshots because the ramp continues moving during capture.
  - This is a technical comparison, not a recommended cadence for fast modulation.
  - A final remainder can be shorter than 256 samples.

## Locked Build Values Applied

- Maximum child chunk size = `256` samples
- Ramp period = `1000` ms
- Fold centre = `0.5`

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id MinimalLargeBufferSplit --agent
hise-cli builder set --module MinimalLargeBufferSplit --network minimal_large_buffer_split --agent

# This large size is a technical zipper-noise comparison, not a recommendation for fast modulation.
hise-cli dsp add --module MinimalLargeBufferSplit --type container.fix256_block --id TwoFiftySixBlocks --agent
# Inspection only: this node may be omitted without changing behavior.
hise-cli dsp add --module MinimalLargeBufferSplit --type analyse.specs --id BlockInspector --parent TwoFiftySixBlocks --agent
hise-cli dsp add --module MinimalLargeBufferSplit --type container.modchain --id StepControl --parent TwoFiftySixBlocks --agent
hise-cli dsp add --module MinimalLargeBufferSplit --type core.ramp --id SourceRamp --parent StepControl --agent
# Fold the one-second ramp around its midpoint to expose the coarse steps.
hise-cli dsp add --module MinimalLargeBufferSplit --type math.sub --id CentreRamp --parent StepControl --agent
hise-cli dsp add --module MinimalLargeBufferSplit --type math.abs --id FoldRamp --parent StepControl --agent
hise-cli dsp add --module MinimalLargeBufferSplit --type core.peak --id ChunkValue --parent StepControl --agent
hise-cli dsp add --module MinimalLargeBufferSplit --type math.add --id StaircaseOutput --parent TwoFiftySixBlocks --agent

hise-cli dsp set --module MinimalLargeBufferSplit --node SourceRamp --param PeriodTime --value 1000 --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node CentreRamp --param Value --value 0.5 --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node StaircaseOutput --param Value --range "0,1" --agent
hise-cli dsp connect --module MinimalLargeBufferSplit --source ChunkValue --target StaircaseOutput --param Value --agent

hise-cli dsp set --module MinimalLargeBufferSplit --node TwoFiftySixBlocks --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node BlockInspector --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node BlockInspector --param Comment --value '"Inspection only: displays the local 256-sample processing specification and may be omitted without changing behavior."' --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node StepControl --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node SourceRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node CentreRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node FoldRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node ChunkValue --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node StaircaseOutput --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node CentreRamp --param Folded --value true --agent
hise-cli dsp set --module MinimalLargeBufferSplit --node FoldRamp --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module MinimalLargeBufferSplit --agent
hise-cli dsp screenshot --module MinimalLargeBufferSplit --scale 200% --output "scriptnode_enrichment/hsc/output/container/fix256_block.png" --agent
```

## Comments To Preserve In HSC

- Before the fixed container: This large chunk size is for technical comparison.
- Before `BlockInspector`: It is design-time inspection only.
- Before `CentreRamp`: Subtract 0.5 and take the absolute value to expose zipper steps.
- Before `StaircaseOutput`: The output is intentionally DC-rich and should be monitored conservatively.

## Documentation Feedback

- Updated Phase 1 and Phase 2 to duplicate the approved folded-triangle demonstration.
- The topology intentionally matches the 128-sample example so the chunk size is the isolated variable.

## Cosmetics Applied

- Main node: `TwoFiftySixBlocks` colour `0xFF2F80ED`
- Support nodes: [`BlockInspector`, `StepControl`, `SourceRamp`, `CentreRamp`, `FoldRamp`, `ChunkValue`, `StaircaseOutput`] colour `0xFF6F8FAF`
- Folded nodes: [`CentreRamp`, `FoldRamp`]

## Defaults Omitted

- `FoldRamp.Value` default `0`
- `StaircaseOutput.Value` default `0`

## Open Issues

- No blocking issue.
