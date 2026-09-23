# container.fix256_block - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/fix256_block.md`
- Reference: `scriptnode_enrichment/output/container/fix256_block.md`

## Naming

- Module ID: `MinimalLargeBufferSplit`
- Network ID: `minimal_large_buffer_split`

## Graph Plan

```text
minimal_large_buffer_split
  TwoFiftySixBlocks      container.fix256_block
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
  - Feed silence and verify once at a host block of at least 512 samples and once at 256 samples or less.
- Channel/routing setup:
  - Required channels: default stereo; control generation uses an isolated mono modchain
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [two host-buffer settings required, DC-rich diagnostic output]

## Public Parameters

- None

## Defaults To Omit

- `FoldRamp.Value` default `0.0`
- `StaircaseOutput.Value` default `0.0`

## Locked Build Values

- Maximum child chunk size = `256` samples
- Subdivision verification host block size = `512` samples
- No-op verification host block size = `256` samples
- `SourceRamp.PeriodTime` = `1000`
- `CentreRamp.Value` = `0.5`
- `ChunkValue` modulation output -> `StaircaseOutput.Value` scaled over `[0, 1]`

## Friction Comments To Weave In

- Before host setup: this largest fixed block only subdivides incoming buffers larger than 256 samples.
- Before `BlockInspector`: this node is inspection-only and may be omitted without changing behavior.
- Before `CentreRamp`: subtract 0.5 and take the absolute value to fold the one-second ramp into an audible triangular staircase.
- Before `StepControl`: source and target stay under the same chunking container.
- Before verification: 256 is a maximum; a final remainder can be shorter.

## Cosmetic Plan

- Main node: `TwoFiftySixBlocks`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`BlockInspector`, `StepControl`, `SourceRamp`, `CentreRamp`, `FoldRamp`, `ChunkValue`, `StaircaseOutput`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`CentreRamp`, `FoldRamp`]
- Nodes that must stay visible: [`TwoFiftySixBlocks`, `BlockInspector`, `StepControl`, `SourceRamp`, `ChunkValue`, `StaircaseOutput`]

## Open Questions

- None
