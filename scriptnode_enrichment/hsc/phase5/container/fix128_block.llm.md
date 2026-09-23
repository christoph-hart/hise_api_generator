---
id: container.fix128_block.lightweight-large-buffer-subdivision
node: container.fix128_block
domain: scriptnode
category: dsp-network
title: "Lightweight Large-Buffer Subdivision"
summary: "Splits the audio buffer into chunks of 128 samples for higher modulation update rates."
useCase: "Demonstrate how `container.fix128_block` improves slow-modulation resolution in large-buffer sessions with very low dispatch overhead."
difficulty: intermediate
networkName: lightweight_large_buffer_subdivision
moduleType: ScriptFX
moduleId: LightweightLargeBufferSubdivision
tags:
  - container
  - fix128
  - block
  - block-size
  - processing-context
aliases:
  - lightweight large-buffer subdivision
  - fix128 block container
relatedNodes:
  - container.fix128_block
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

scriptnode example: container.fix128_block

Lightweight Large-Buffer Subdivision.

Demonstrate how `container.fix128_block` improves slow-modulation resolution in large-buffer sessions with very low dispatch overhead.

Graph:
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

Host:
  Module: LightweightLargeBufferSubdivision
  Network: lightweight_large_buffer_subdivision
  Host context: Script FX
  Required channels: default stereo; isolated mono modulation path
  Module routing: default stereo
  Master routing: default stereo
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "LightweightLargeBufferSubdivision"`, then set its network to `lightweight_large_buffer_subdivision`.

Support nodes:
  Required: analyse.specs, container.modchain, core.ramp, math.sub, math.abs, core.peak, math.add
  `analyse.specs` displays the local block size for inspection only; `container.modchain` provides an isolated control path; `core.ramp`, `math.sub`, and `math.abs` create the folded triangle; `core.peak` exports one value per 128-sample chunk; and `math.add` makes the coarse holds visible and audible.

Key rules:
  - Before the fixed container: This large size is for technical comparison rather than fast practical modulation.
  - Before BlockInspector: It is design-time inspection only.
  - Before CentreRamp: Subtract 0.5 and take the absolute value to expose zipper steps.
  - Before StaircaseOutput: The output is intentionally DC-rich and should be monitored conservatively.

Public controls:
  - None

HISE CLI build commands:
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

