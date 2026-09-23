---
id: container.fix256_block.minimal-large-buffer-split
node: container.fix256_block
domain: scriptnode
category: dsp-network
title: "Minimal Large-Buffer Split"
summary: "Splits the audio buffer into chunks of 256 samples for higher modulation update rates."
useCase: "Demonstrate the host-buffer dependency and deliberately coarse update resolution of the largest fixed-block container."
difficulty: intermediate
networkName: minimal_large_buffer_split
moduleType: ScriptFX
moduleId: MinimalLargeBufferSplit
tags:
  - container
  - fix256
  - block
  - block-size
  - processing-context
aliases:
  - minimal large-buffer split
  - fix256 block container
relatedNodes:
  - container.fix256_block
  - analyse.specs
  - container.modchain
  - core.ramp
  - math.sub
  - math.abs
  - core.peak
  - math.add
parameters:
  None: "None"
---

scriptnode example: container.fix256_block

Minimal Large-Buffer Split.

Demonstrate the host-buffer dependency and deliberately coarse update resolution of the largest fixed-block container.

Graph:
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

Host:
  Module: MinimalLargeBufferSplit
  Network: minimal_large_buffer_split
  Host context: Script FX
  Required channels: default stereo; isolated mono modulation path
  Module routing: default stereo
  Master routing: default stereo
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "MinimalLargeBufferSplit"`, then set its network to `minimal_large_buffer_split`.

Support nodes:
  Required: analyse.specs, container.modchain, core.ramp, math.sub, math.abs, core.peak, math.add
  `analyse.specs` displays the local block size for inspection only; `container.modchain` isolates control generation; `core.ramp`, `math.sub`, and `math.abs` create the folded triangle; `core.peak` samples it once per chunk; and `math.add` renders the resulting 256-sample plateaus.

Key rules:
  - Before the fixed container: This large chunk size is for technical comparison.
  - Before BlockInspector: It is design-time inspection only.
  - Before CentreRamp: Subtract 0.5 and take the absolute value to expose zipper steps.
  - Before StaircaseOutput: The output is intentionally DC-rich and should be monitored conservatively.

Public controls:
  - None

HISE CLI build commands:
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

