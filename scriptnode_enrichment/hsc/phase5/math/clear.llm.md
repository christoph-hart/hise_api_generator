---
id: math.clear.branch-layer-reset
node: math.clear
domain: scriptnode
category: dsp-network
title: Branch layer reset
summary: Uses math.clear at the start of a split branch to erase inherited audio before generating a replacement layer.
useCase: Use this to initialize a replacement branch from silence so the original split signal does not leak into it.
difficulty: beginner
networkName: branch_layer_reset
moduleType: ScriptFX
moduleId: BranchLayerReset
tags:
  - signal-reset
  - branch-routing
  - silence
aliases:
  - clear branch
  - replacement layer reset
relatedNodes:
  - math.clear
  - container.split
  - container.chain
  - core.oscillator
  - core.gain
parameters:
  BranchReset.Value: Unused interface parameter; math.clear always writes silence.
---

scriptnode example: math.clear

Branch layer reset.
Use this to demonstrate branch initialization. The split input remains available on the dry branch, while the replacement branch clears inherited audio before adding its own oscillator layer.

Graph:
```text
branch_layer_reset
  LayerSplit            container.split
    DryBranch           container.chain
    ReplacementBranch   container.chain
      BranchReset       math.clear
      ReplacementOsc    core.oscillator
      ReplacementTrim   core.gain
```

Host:
  Module: `BranchLayerReset`
  Type: `ScriptFX`
  Network: `branch_layer_reset`
  Builder setup: `add ScriptFX as "BranchLayerReset"`, then set its network to `branch_layer_reset`.

Support nodes:
  Required: `container.split`, `container.chain`, `core.oscillator`, `core.gain`

Key rules:
  - Place `math.clear` at the start of the replacement branch, not only at the end of the graph.
  - The dry branch demonstrates the inherited signal that would otherwise leak into the replacement branch.
  - `math.clear.Value` is not used in processing and remains at its default.

Public controls:
  - None; the oscillator and trim values are fixed demonstration settings.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id BranchLayerReset --agent
hise-cli builder set --module BranchLayerReset --network branch_layer_reset --agent
hise-cli dsp add --module BranchLayerReset --type container.split --id LayerSplit --agent
hise-cli dsp add --module BranchLayerReset --type container.chain --id DryBranch --parent LayerSplit --agent
hise-cli dsp add --module BranchLayerReset --type container.chain --id ReplacementBranch --parent LayerSplit --agent
hise-cli dsp add --module BranchLayerReset --type math.clear --id BranchReset --parent ReplacementBranch --agent
hise-cli dsp add --module BranchLayerReset --type core.oscillator --id ReplacementOsc --parent ReplacementBranch --agent
hise-cli dsp set --module BranchLayerReset --node ReplacementOsc --param Frequency --value 220 --agent
hise-cli dsp add --module BranchLayerReset --type core.gain --id ReplacementTrim --parent ReplacementBranch --agent
hise-cli dsp set --module BranchLayerReset --node ReplacementTrim --param Gain --value -12 --agent
```
