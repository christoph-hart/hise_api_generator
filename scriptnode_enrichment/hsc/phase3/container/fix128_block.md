# container.fix128_block - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/fix128_block.md`
- Reference: `scriptnode_enrichment/output/container/fix128_block.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as a technical zipper-noise demonstration duplicating the folded-triangle topology from `container.dynamic_blocksize`.

## Naming

- Module ID: `LightweightLargeBufferSubdivision`
- Network ID: `lightweight_large_buffer_subdivision`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied:
  - Used silent input because `StaircaseOutput` intentionally generates a DC-rich diagnostic signal.
  - Added `BlockInspector` for design-time inspection only.
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

- Parameter trace command:
  - `hise-cli dsp trace --module LightweightLargeBufferSubdivision --container lightweight_large_buffer_subdivision --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent`
- Parameter trace evidence:
  - `StaircaseOutput.Value` was observed at `0.0795` while the touched edge showed a later moving value of `0.1008`.
- Signal trace evidence:
  - Root specs reported `sampleRate=48000`, `numChannels=2`, `blockSize=512`.
  - `OneTwentyEightBlocks` reported `blockSize=128`.
  - `StepControl` reported `sampleRate=6000`, `numChannels=1`, `blockSize=16`.
  - The ramp, subtraction, absolute value, peak exporter, and additive output all produced the expected folded control values.
- Trace caveats:
  - Values differ slightly across snapshots because the ramp continues moving during capture.
  - 128 samples is a maximum chunk size; a final remainder can be shorter.

## Locked Build Values Applied

- Maximum child chunk size = `128` samples
- Ramp period = `1000` ms
- Fold centre = `0.5`

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id LightweightLargeBufferSubdivision --agent
hise-cli builder set --module LightweightLargeBufferSubdivision --network lightweight_large_buffer_subdivision --agent

# This is a technical zipper-noise comparison, not a recommendation for fast parameter modulation.
hise-cli dsp add --module LightweightLargeBufferSubdivision --type container.fix128_block --id OneTwentyEightBlocks --agent
# Inspection only: this node may be omitted without changing behavior.
hise-cli dsp add --module LightweightLargeBufferSubdivision --type analyse.specs --id BlockInspector --parent OneTwentyEightBlocks --agent
hise-cli dsp add --module LightweightLargeBufferSubdivision --type container.modchain --id StepControl --parent OneTwentyEightBlocks --agent
hise-cli dsp add --module LightweightLargeBufferSubdivision --type core.ramp --id SourceRamp --parent StepControl --agent
# Fold the one-second ramp around its midpoint to make the coarse zipper steps easier to hear.
hise-cli dsp add --module LightweightLargeBufferSubdivision --type math.sub --id CentreRamp --parent StepControl --agent
hise-cli dsp add --module LightweightLargeBufferSubdivision --type math.abs --id FoldRamp --parent StepControl --agent
hise-cli dsp add --module LightweightLargeBufferSubdivision --type core.peak --id ChunkValue --parent StepControl --agent
hise-cli dsp add --module LightweightLargeBufferSubdivision --type math.add --id StaircaseOutput --parent OneTwentyEightBlocks --agent

hise-cli dsp set --module LightweightLargeBufferSubdivision --node SourceRamp --param PeriodTime --value 1000 --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node CentreRamp --param Value --value 0.5 --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node StaircaseOutput --param Value --range "0,1" --agent
hise-cli dsp connect --module LightweightLargeBufferSubdivision --source ChunkValue --target StaircaseOutput --param Value --agent

hise-cli dsp set --module LightweightLargeBufferSubdivision --node OneTwentyEightBlocks --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node BlockInspector --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node BlockInspector --param Comment --value '"Inspection only: displays the local 128-sample processing specification and may be omitted without changing behavior."' --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node StepControl --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node SourceRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node CentreRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node FoldRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node ChunkValue --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node StaircaseOutput --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node CentreRamp --param Folded --value true --agent
hise-cli dsp set --module LightweightLargeBufferSubdivision --node FoldRamp --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module LightweightLargeBufferSubdivision --agent
hise-cli dsp screenshot --module LightweightLargeBufferSubdivision --scale 200% --output "scriptnode_enrichment/hsc/output/container/fix128_block.png" --agent
```

## Comments To Preserve In HSC

- Before the fixed container: This large size is for technical comparison rather than fast practical modulation.
- Before `BlockInspector`: It is design-time inspection only.
- Before `CentreRamp`: Subtract 0.5 and take the absolute value to expose zipper steps.
- Before `StaircaseOutput`: The output is intentionally DC-rich and should be monitored conservatively.

## Documentation Feedback

- Updated Phase 1 and Phase 2 to duplicate the approved folded-triangle demonstration.
- The main container Comment remains an HSC comment because of the known Comment parser issue.

## Cosmetics Applied

- Main node: `OneTwentyEightBlocks` colour `0xFF2F80ED`
- Support nodes: [`BlockInspector`, `StepControl`, `SourceRamp`, `CentreRamp`, `FoldRamp`, `ChunkValue`, `StaircaseOutput`] colour `0xFF6F8FAF`
- Folded nodes: [`CentreRamp`, `FoldRamp`]

## Defaults Omitted

- `FoldRamp.Value` default `0`
- `StaircaseOutput.Value` default `0`

## Open Issues

- No blocking issue. The known generic Comment setter issue is documented separately.
