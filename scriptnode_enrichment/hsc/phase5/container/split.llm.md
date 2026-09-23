---
id: container.split.phase-cancellation-silencer
node: container.split
domain: scriptnode
category: dsp-network
title: "Phase-Cancellation Silencer"
summary: "A parallel container that copies the input to each child and sums their outputs."
useCase: "Demonstrate that `container.split` gives every child the same unmodified input and sums aligned outputs without introducing a child-to-child signal dependency or delay."
difficulty: beginner
networkName: phase_cancellation_silencer
moduleType: ScriptFX
moduleId: PhaseCancellationSilencer
tags:
  - container
  - split
  - routing
  - parallel-processing
aliases:
  - phase-cancellation silencer
  - split container
relatedNodes:
  - container.split
  - math.mul
parameters:
  None: "None"
---

scriptnode example: container.split

Phase-Cancellation Silencer.

Demonstrate that `container.split` gives every child the same unmodified input and sums aligned outputs without introducing a child-to-child signal dependency or delay.

Graph:
```text
phase_cancellation_silencer
  CancellationPaths      container.split
    PositivePath         math.mul
    InvertedPath         math.mul
```

Host:
  Module: PhaseCancellationSilencer
  Network: phase_cancellation_silencer
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "PhaseCancellationSilencer"`, then set its network to `phase_cancellation_silencer`.

Support nodes:
  Required: math.mul
  Two `math.mul` instances create the matched +1 and -1 paths needed for deterministic cancellation; the first also makes both branches structurally explicit instead of relying on an empty child as passthrough.

Key rules:
  - Unexpected gain increase from summing: Split sums all child outputs together. Two children at unity gain produce twice the amplitude. Scale each child or the combined output to maintain the expected level.

Public controls:
  - None

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id PhaseCancellationSilencer --agent
hise-cli builder set --module PhaseCancellationSilencer --network phase_cancellation_silencer --agent

# split copies the untouched input to every child and sums their aligned outputs.
hise-cli dsp add --module PhaseCancellationSilencer --type container.split --id CancellationPaths --agent
hise-cli dsp add --module PhaseCancellationSilencer --type math.mul --id PositivePath --parent CancellationPaths --agent
hise-cli dsp add --module PhaseCancellationSilencer --type math.mul --id InvertedPath --parent CancellationPaths --agent
# Widen the multiplier before setting the locked negative value.
hise-cli dsp set --module PhaseCancellationSilencer --node InvertedPath --param Value --range "-1,1" --stepSize 0 --agent
hise-cli dsp set --module PhaseCancellationSilencer --node InvertedPath --param Value --value -1 --agent

hise-cli dsp set --module PhaseCancellationSilencer --node CancellationPaths --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module PhaseCancellationSilencer --node CancellationPaths --param Comment --value '"split copies the same aligned stereo input to both children, then sums their outputs."' --agent
hise-cli dsp set --module PhaseCancellationSilencer --node PositivePath --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module PhaseCancellationSilencer --node PositivePath --param Comment --value '"Passes the copied input unchanged at gain +1."' --agent
hise-cli dsp set --module PhaseCancellationSilencer --node InvertedPath --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module PhaseCancellationSilencer --node InvertedPath --param Comment --value '"Multiplies the second aligned copy by -1, producing exact cancellation without compensation gain."' --agent
```

