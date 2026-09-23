---
id: container.dynamic_blocksize.adjustable-modulation-staircase
node: container.dynamic_blocksize
domain: scriptnode
category: dsp-network
title: "Adjustable Modulation Staircase"
summary: "Processes children with a parameter-controlled block size, allowing runtime quality settings down to per-sample frame processing."
useCase: "Demonstrate that `container.dynamic_blocksize` changes child update granularity at runtime and exposes the resulting precision-versus-processing tradeoff."
difficulty: advanced
networkName: adjustable_modulation_staircase
moduleType: ScriptFX
moduleId: AdjustableModulationStaircase
tags:
  - container
  - dynamic
  - blocksize
  - block-size
  - processing-context
aliases:
  - adjustable modulation staircase
  - dynamic blocksize container
relatedNodes:
  - container.dynamic_blocksize
  - analyse.specs
  - container.modchain
  - core.ramp
  - math.sub
  - math.abs
  - core.peak
  - math.add
parameters:
  BlockSize: "BlockSize -> AdjustableBlocks.BlockSize matched"
  Target: "Target range before connection: [0, 7], step 1"
  Macro: "Macro range: [0, 7], step 1, labels 1, 8, 16, 32, 64, 128, 256, 512"
  Default:: "Default: 4"
---

scriptnode example: container.dynamic_blocksize

Adjustable Modulation Staircase.

Demonstrate that `container.dynamic_blocksize` changes child update granularity at runtime and exposes the resulting precision-versus-processing tradeoff.

Graph:
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

Host:
  Module: AdjustableModulationStaircase
  Network: adjustable_modulation_staircase
  Host context: Script FX
  Required channels: default stereo; StepControl uses an isolated mono control buffer
  Module routing: default stereo
  Master routing: default stereo
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "AdjustableModulationStaircase"`, then set its network to `adjustable_modulation_staircase`.

Support nodes:
  Required: analyse.specs, container.modchain, core.ramp, math.sub, math.abs, core.peak, math.add
  `analyse.specs` displays the selected local block size for inspection only and is not load-bearing; `container.modchain` creates an isolated mono control path inside the selected block context; `core.ramp` generates a slow 0 to 1 source; `math.sub` and `math.abs` centre and fold it into a repeating triangular control shape; `core.peak` exports each processed chunk's value as modulation; and `math.add` converts those discrete parameter updates into an audible staircase on an otherwise silent signal.

Key rules:
  - Before BlockSize: The raw value is an index into [1, 8, 16, 32, 64, 128, 256, 512], not a sample count.
  - Before BlockInspector: This design-time node is for visible inspection only and may be omitted without changing behavior.
  - Before StepControl: The modulation source and target remain inside the dynamic container so they share its cadence.
  - Before CentreRamp: Subtract 0.5 and take the absolute value to fold the one-second ramp into an audible triangular staircase.
  - Before StaircaseOutput: The additive node intentionally emits a unipolar DC-rich diagnostic signal from silence.
  - Setting parameter to the actual block size: The parameter value is an index into a fixed array of valid block sizes, not the block size itself. This ensures only valid power-of-two sizes are used.

Public controls:
  - BlockSize -> AdjustableBlocks.BlockSize matched
  - Target range before connection: [0, 7], step 1
  - Macro range: [0, 7], step 1, labels 1, 8, 16, 32, 64, 128, 256, 512
  - Default: 4

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id AdjustableModulationStaircase --agent
hise-cli builder set --module AdjustableModulationStaircase --network adjustable_modulation_staircase --agent

hise-cli dsp add --module AdjustableModulationStaircase --type container.dynamic_blocksize --id AdjustableBlocks --agent
# Inspection only: BlockInspector displays local specs and may be omitted without changing behavior.
hise-cli dsp add --module AdjustableModulationStaircase --type analyse.specs --id BlockInspector --parent AdjustableBlocks --agent
hise-cli dsp add --module AdjustableModulationStaircase --type container.modchain --id StepControl --parent AdjustableBlocks --agent
hise-cli dsp add --module AdjustableModulationStaircase --type core.ramp --id SourceRamp --parent StepControl --agent
hise-cli dsp add --module AdjustableModulationStaircase --type math.sub --id CentreRamp --parent StepControl --agent
hise-cli dsp add --module AdjustableModulationStaircase --type math.abs --id FoldRamp --parent StepControl --agent
hise-cli dsp add --module AdjustableModulationStaircase --type core.peak --id ChunkValue --parent StepControl --agent
# This additive stage intentionally turns the held control value into a DC-rich audible staircase.
hise-cli dsp add --module AdjustableModulationStaircase --type math.add --id StaircaseOutput --parent AdjustableBlocks --agent

hise-cli dsp set --module AdjustableModulationStaircase --node SourceRamp --param PeriodTime --value 1000 --agent
hise-cli dsp set --module AdjustableModulationStaircase --node CentreRamp --param Value --value 0.5 --agent
hise-cli dsp set --module AdjustableModulationStaircase --node StaircaseOutput --param Value --range "0,1" --agent
hise-cli dsp create_parameter --module AdjustableModulationStaircase --container adjustable_modulation_staircase --id BlockSize --range "0,7" --default 4 --stepSize 1 --agent
hise-cli dsp connect --module AdjustableModulationStaircase --source adjustable_modulation_staircase --source-param BlockSize --target AdjustableBlocks --param BlockSize --matched --agent
# Expose BlockSize so the root cable is visible on the inner container.
hise-cli dsp set --module AdjustableModulationStaircase --node AdjustableBlocks --param ShowParameters --value true --agent
hise-cli dsp connect --module AdjustableModulationStaircase --source ChunkValue --target StaircaseOutput --param Value --agent

hise-cli dsp set --module AdjustableModulationStaircase --node AdjustableBlocks --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module AdjustableModulationStaircase --node AdjustableBlocks --param Comment --value '"**Adjustable modulation staircase** - BlockSize selects child processing chunks from one sample through 512 samples."' --agent
hise-cli dsp set --module AdjustableModulationStaircase --node BlockInspector --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node BlockInspector --param Comment --value '"Inspection only: displays local processing specifications and does not affect signal flow or block-size behavior."' --agent
hise-cli dsp set --module AdjustableModulationStaircase --node StepControl --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node StepControl --param Comment --value '"The one-second ramp is folded into a slow triangle so coarse block updates become audible zipper steps."' --agent
hise-cli dsp set --module AdjustableModulationStaircase --node SourceRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node CentreRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node FoldRamp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node ChunkValue --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node StaircaseOutput --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module AdjustableModulationStaircase --node CentreRamp --param Folded --value true --agent
hise-cli dsp set --module AdjustableModulationStaircase --node FoldRamp --param Folded --value true --agent
```

