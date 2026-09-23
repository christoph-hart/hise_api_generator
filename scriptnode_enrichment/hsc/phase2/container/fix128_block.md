# container.fix128_block - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/fix128_block.md`
- Reference: `scriptnode_enrichment/output/container/fix128_block.md`

## Naming

- Module ID: `LightweightLargeBufferSubdivision`
- Network ID: `lightweight_large_buffer_subdivision`

## Graph Plan

```text
lightweight_large_buffer_subdivision
  OneTwentyEightBlocks   container.fix128_block
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
  - Set the host buffer to 512 or 1024 samples and feed silence for waveform verification.
- Channel/routing setup:
  - Required channels: default stereo; control generation uses an isolated mono modchain
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [large-host-buffer verification, DC-rich diagnostic output]

## Public Parameters

- None

## Defaults To Omit

- `FoldRamp.Value` default `0.0`
- `StaircaseOutput.Value` default `0.0`

## Locked Build Values

- Maximum child chunk size = `128` samples
- Verification host block size = `512` or `1024` samples
- `SourceRamp.PeriodTime` = `1000`
- `CentreRamp.Value` = `0.5`
- `ChunkValue` output range = `[0, 1]`
- `StaircaseOutput.Value` range = `[0, 1]`
- `ChunkValue` modulation output -> `StaircaseOutput.Value` scaled

## Friction Comments To Weave In

- Before host setup: a large host block is required to show multiple 128-sample levels per callback.
- Before `BlockInspector`: this node is inspection-only and may be omitted without changing behavior.
- Before `CentreRamp`: subtract 0.5 and take the absolute value to fold the one-second ramp into an audible triangular staircase.
- Before `StepControl`: the source and additive target share the subdivided callback context.
- Before verification: bypass re-prepares children at the full host block size.

## Cosmetic Plan

- Main node: `OneTwentyEightBlocks`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`BlockInspector`, `StepControl`, `SourceRamp`, `CentreRamp`, `FoldRamp`, `ChunkValue`, `StaircaseOutput`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`CentreRamp`, `FoldRamp`]
- Nodes that must stay visible: [`OneTwentyEightBlocks`, `BlockInspector`, `StepControl`, `SourceRamp`, `ChunkValue`, `StaircaseOutput`]

## Open Questions

- None
