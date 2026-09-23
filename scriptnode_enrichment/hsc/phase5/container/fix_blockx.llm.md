---
id: container.fix_blockx.legacy-design-time-block-selection
node: container.fix_blockx
domain: scriptnode
category: dsp-network
title: "Legacy Design-Time Block Selection"
summary: "Splits the audio buffer into chunks with a property-selectable block size for evaluating different tradeoffs during development."
useCase: "Document `container.fix_blockx` for compatibility while explaining that it is effectively deprecated: prefer `container.dynamic_blocksize` for runtime selection or a `container.fixN_block` node when the size is known."
difficulty: intermediate
networkName: design_time_block_audition
moduleType: ScriptFX
moduleId: DesignTimeBlockAudition
tags:
  - container
  - fix
  - blockx
  - block-size
  - processing-context
aliases:
  - legacy design-time block selection
  - fix blockx container
relatedNodes:
  - container.fix_blockx
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

scriptnode example: container.fix_blockx

Legacy Design-Time Block Selection.

Document `container.fix_blockx` for compatibility while explaining that it is effectively deprecated: prefer `container.dynamic_blocksize` for runtime selection or a `container.fixN_block` node when the size is known.

Graph:
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

Host:
  Module: DesignTimeBlockAudition
  Network: design_time_block_audition
  Host context: Script FX
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "DesignTimeBlockAudition"`, then set its network to `design_time_block_audition`.

Support nodes:
  Required: analyse.specs, container.modchain, core.ramp, math.sub, math.abs, core.peak, math.add
  `analyse.specs` displays the selected local size for inspection only; `container.modchain` isolates control generation; `core.ramp`, `math.sub`, and `math.abs` produce the same folded triangle used by the dynamic example; `core.peak` exports one value per chunk; and `math.add` renders the selected cadence as audible zipper steps.

Key rules:
  - This is a legacy compatibility example; do not use link-token syntax in example comments.
  - Prefer dynamic runtime selection or a static fixed-size container in new networks.
  - BlockInspector is inspection-only.
  - The additive staircase is intentionally DC-rich.
  - BlockSize property not visible: The BlockSize property is hidden by default. The parameter button in the node header toggles visibility of node properties.

Public controls:
  - None

HISE CLI build commands:
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

