# container.fix_blockx - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/container/fix_blockx.md`
- Reference: `scriptnode_enrichment/output/container/fix_blockx.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Approved as a legacy compatibility example. It duplicates the folded-triangle dynamic-blocksize topology without exposing a root BlockSize parameter.

## Naming

- Module ID: `DesignTimeBlockAudition`
- Network ID: `design_time_block_audition`

## Builder Setup Applied

- Host context: `Script FX`
- BlockSize property: `64`
- Input: silence
- `BlockInspector` is design-time inspection only and may be omitted.

## Verified Parameters

- `FixedBlocks.BlockSize` property = `64`
- `SourceRamp.PeriodTime` = `1000`
- `CentreRamp.Value` = `0.5`
- `StaircaseOutput.Value` range = `0..1`

## Verified Connections

- `ChunkValue.0` -> `StaircaseOutput.Value` scaled: true

## Trace Validation

- Command:
  - `hise-cli dsp trace --module DesignTimeBlockAudition --container design_time_block_audition --inject silence --probe-recursive --probe-changed-parameters --trace-compact --agent`
- Evidence:
  - Root block size: `512`
  - `FixedBlocks` block size: `64`
  - `StepControl`: 6000 Hz control rate, block size `8`
  - Ramp: `0.3582`
  - Centred ramp: `-0.143`
  - Folded value: `0.143`
  - Staircase output: approximately `0.143`
- Caveats:
  - This node is effectively deprecated for new networks.
  - Prefer the dynamic block-size container for runtime selection or a static fixed-size container when the size is known.
  - A final remainder chunk can be shorter than the selected size.

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DesignTimeBlockAudition --agent
hise-cli builder set --module DesignTimeBlockAudition --network design_time_block_audition --agent

# Legacy compatibility only: prefer a dynamic or static fixed-size block container for new networks.
hise-cli dsp add --module DesignTimeBlockAudition --type container.fix_blockx --id FixedBlocks --agent
# Inspection only: this node may be omitted without changing behavior.
hise-cli dsp add --module DesignTimeBlockAudition --type analyse.specs --id BlockInspector --parent FixedBlocks --agent
hise-cli dsp add --module DesignTimeBlockAudition --type container.modchain --id StepControl --parent FixedBlocks --agent
hise-cli dsp add --module DesignTimeBlockAudition --type core.ramp --id SourceRamp --parent StepControl --agent
hise-cli dsp add --module DesignTimeBlockAudition --type math.sub --id CentreRamp --parent StepControl --agent
hise-cli dsp add --module DesignTimeBlockAudition --type math.abs --id FoldRamp --parent StepControl --agent
hise-cli dsp add --module DesignTimeBlockAudition --type core.peak --id ChunkValue --parent StepControl --agent
hise-cli dsp add --module DesignTimeBlockAudition --type math.add --id StaircaseOutput --parent FixedBlocks --agent

hise-cli dsp set --module DesignTimeBlockAudition --node FixedBlocks --param BlockSize --value 64 --agent
hise-cli dsp set --module DesignTimeBlockAudition --node SourceRamp --param PeriodTime --value 1000 --agent
hise-cli dsp set --module DesignTimeBlockAudition --node CentreRamp --param Value --value 0.5 --agent
hise-cli dsp set --module DesignTimeBlockAudition --node StaircaseOutput --param Value --range "0,1" --agent
hise-cli dsp connect --module DesignTimeBlockAudition --source ChunkValue --target StaircaseOutput --param Value --agent

hise-cli dsp set --module DesignTimeBlockAudition --node FixedBlocks --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module DesignTimeBlockAudition --node FixedBlocks --param Comment --value '"**Legacy design-time block selector** - Prefer the dynamic block-size container for runtime selection or a static fixed-size container when the size is known."' --agent
hise-cli dsp set --module DesignTimeBlockAudition --node BlockInspector --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module DesignTimeBlockAudition --node BlockInspector --param Comment --value '"Inspection only: displays the property-selected local block size and may be omitted without changing behavior."' --agent
hise-cli dsp set --module DesignTimeBlockAudition --node StepControl --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module DesignTimeBlockAudition --node SourceRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module DesignTimeBlockAudition --node CentreRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module DesignTimeBlockAudition --node FoldRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module DesignTimeBlockAudition --node ChunkValue --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module DesignTimeBlockAudition --node StaircaseOutput --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module DesignTimeBlockAudition --node CentreRamp --param Folded --value true --agent
hise-cli dsp set --module DesignTimeBlockAudition --node FoldRamp --param Folded --value true --agent
```

## Pipeline-Only Commands

```bash
hise-cli dsp save --module DesignTimeBlockAudition --agent
hise-cli dsp screenshot --module DesignTimeBlockAudition --scale 200% --output "scriptnode_enrichment/hsc/output/container/fix_blockx.png" --agent
```

## Comments To Preserve In HSC

- This is a legacy compatibility example; do not use link-token syntax in example comments.
- Prefer dynamic runtime selection or a static fixed-size container in new networks.
- `BlockInspector` is inspection-only.
- The additive staircase is intentionally DC-rich.

## Cosmetics Applied

- Main node: `FixedBlocks` colour `0xFF2F80ED`
- Support nodes: [`BlockInspector`, `StepControl`, `SourceRamp`, `CentreRamp`, `FoldRamp`, `ChunkValue`, `StaircaseOutput`] colour `0xFF6F8FAF`
- Folded nodes: [`CentreRamp`, `FoldRamp`]

## Defaults Omitted

- `FoldRamp.Value` default `0`
- `StaircaseOutput.Value` default `0`

## Open Issues

- None blocking this artifact.
