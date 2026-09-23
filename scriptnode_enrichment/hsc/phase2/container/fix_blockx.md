# container.fix_blockx - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/fix_blockx.md`
- Reference: `scriptnode_enrichment/output/container/fix_blockx.md`

## Naming

- Module ID: `DesignTimeBlockAudition`
- Network ID: `design_time_block_audition`

## Graph Plan

```text
design_time_block_audition
  FixedBlocks            container.fix_blockx
    BlockInspector       analyse.specs
    StepControl          container.modchain
      SourceRamp         core.ramp
      CentreRamp         math.sub
      FoldRamp           math.abs
      ChunkValue         core.peak
    StaircaseOutput      math.add
```

## Builder Setup

- Host context: `Script FX`
- Additional builder steps:
  - Feed silence into the Script FX and use waveform inspection at a safe monitoring level.
  - This is the `container.dynamic_blocksize` folded-triangle example without a mapped root parameter.
  - Treat the node as legacy: prefer `container.dynamic_blocksize` or a static `container.fixN_block` for new networks.
- Channel/routing setup:
  - Required channels: default stereo; control generation uses an isolated mono modchain
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [silent-input diagnostic generator]

## Public Parameters

- None

## Defaults To Omit

- `FoldRamp.Value` default `0.0`
- `StaircaseOutput.Value` default `0.0`

## Locked Build Values

- `FixedBlocks.BlockSize` property = `64`
- Available BlockSize property values = `8, 16, 32, 64, 128, 256`
- `SourceRamp.PeriodTime` = `1000`
- `CentreRamp.Value` = `0.5`
- `ChunkValue` output range = `[0, 1]`
- `StaircaseOutput.Value` range = `[0, 1]`
- `ChunkValue` modulation output -> `StaircaseOutput.Value` scaled

## Friction Comments To Weave In

- Before BlockSize setup: this hidden property is a legacy design-time choice. Link to `container.dynamic_blocksize` for runtime control and the static fixed-size containers when the size is known.
- Before `BlockInspector`: this node is inspection-only and may be omitted without changing behavior.
- Before `CentreRamp`: subtract 0.5 and take the absolute value to duplicate the dynamic example's triangle fold.
- Before `StepControl`: source and target remain inside the container so both use the selected chunk cadence.
- Before auditioning: the additive staircase is intentionally DC-rich and should be inspected visually.

## Cosmetic Plan

- Main node: `FixedBlocks`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`BlockInspector`, `StepControl`, `SourceRamp`, `CentreRamp`, `FoldRamp`, `ChunkValue`, `StaircaseOutput`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`CentreRamp`, `FoldRamp`]
- Nodes that must stay visible: [`FixedBlocks`, `BlockInspector`, `StepControl`, `SourceRamp`, `ChunkValue`, `StaircaseOutput`]

## Open Questions

- None
