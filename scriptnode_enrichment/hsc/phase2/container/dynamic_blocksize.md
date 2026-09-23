# container.dynamic_blocksize - HSC Topology Plan

## Source

- Phase 1: `scriptnode_enrichment/hsc/phase1/container/dynamic_blocksize.md`
- Reference: `scriptnode_enrichment/output/container/dynamic_blocksize.md`

## Naming

- Module ID: `AdjustableModulationStaircase`
- Network ID: `adjustable_modulation_staircase`

## Graph Plan

```text
adjustable_modulation_staircase
  AdjustableBlocks       container.dynamic_blocksize
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
  - Feed silence into the Script FX and use waveform inspection; monitor the DC-rich output at a safe level.
- Channel/routing setup:
  - Required channels: default stereo; control generation uses an isolated mono modchain
  - Module routing: default
  - Master routing: default
  - Channel-specific comments needed: [silent-input diagnostic generator]

## Public Parameters

- BlockSize -> `AdjustableBlocks.BlockSize` matched
- Target range before connection: `[0, 7]`, step `1`
- Macro range: `[0, 7]`, step `1`, labels `1, 8, 16, 32, 64, 128, 256, 512`
- Default: `4`

## Defaults To Omit

- `AdjustableBlocks.BlockSize` default `4`
- `FoldRamp.Value` default `0.0`
- `StaircaseOutput.Value` default `0.0`

## Locked Build Values

- Raw BlockSize index table = `[1, 8, 16, 32, 64, 128, 256, 512]`
- `SourceRamp.PeriodTime` = `1000`
- `CentreRamp.Value` = `0.5`
- `ChunkValue` output range = `[0, 1]`
- `StaircaseOutput.Value` range = `[0, 1]`
- `ChunkValue` modulation output -> `StaircaseOutput.Value` matched
- Visual verification startup BlockSize index = `4` (`64` samples)

## Friction Comments To Weave In

- Before BlockSize: the raw value is an index into the locked size table, not a sample count.
- Before `BlockInspector`: this node is for visible inspection only and may be omitted without changing signal flow or block-size behavior.
- Before `StepControl`: source and target must both remain inside the block-size container so they share its cadence.
- Before `CentreRamp`: subtract `0.5` and take the absolute value to fold the slow one-second ramp into a repeating triangular control shape; this makes coarse zipper steps easier to hear.
- Before auditioning: `math.add` intentionally emits a unipolar DC-rich diagnostic staircase from silence.

## Cosmetic Plan

- Main node: `AdjustableBlocks`
- Accent colour: `0xFF2F80ED`
- Supporting relevant nodes: [`BlockInspector`, `StepControl`, `SourceRamp`, `ChunkValue`, `StaircaseOutput`]
- Supporting colour: `0xFF6F8FAF`
- Folded nodes: [`CentreRamp`, `FoldRamp`]
- ShowParameters containers: [`AdjustableBlocks`]
- Nodes that must stay visible: [`AdjustableBlocks`, `BlockInspector`, `StepControl`, `ChunkValue`, `StaircaseOutput`]

## Open Questions

- None
