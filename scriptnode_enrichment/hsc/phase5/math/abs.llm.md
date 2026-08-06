---
id: math.abs.folded-triangle-shaper
node: math.abs
domain: scriptnode
category: dsp-network
title: Folded triangle shaper
summary: Uses math.abs to fold a bipolar ramp into a visible non-negative triangle-like shape.
useCase: Use this for continuous full-wave rectification of audio or modulation signals.
difficulty: beginner
networkName: folded_triangle_shaper
moduleType: ScriptFX
moduleId: FoldedTriangleShaper
tags:
  - absolute-value
  - rectification
  - waveshaping
aliases:
  - full-wave rectifier
  - absolute fold
relatedNodes:
  - math.abs
  - core.ramp
  - math.add
  - math.mul
  - core.peak
  - math.clear
parameters:
  FoldShape.Value: Unused interface parameter; math.abs continuously folds negative values upward.
---

scriptnode example: math.abs

Folded triangle shaper.
Use this to demonstrate continuous full-wave rectification. The ramp is centered and scaled into a bipolar signal before `math.abs` folds its negative half upward.

Graph:
```text
folded_triangle_shaper
  SlowRamp              core.ramp
  BipolarOffset         math.add
  BipolarScale          math.mul
  FoldShape             math.abs
  OutputPeak            core.peak
  SignalClear           math.clear
```

Host:
  Module: `FoldedTriangleShaper`
  Type: `ScriptFX`
  Network: `folded_triangle_shaper`
  Builder setup: `add ScriptFX as "FoldedTriangleShaper"`, then set its network to `folded_triangle_shaper`.

Support nodes:
  Required: `core.ramp`, `math.add`, `math.mul`, `core.peak`, `math.clear`

Key rules:
  - Center and scale the ramp before the fold so the input is bipolar.
  - `math.abs` is continuous full-wave rectification; `math.rect` is a different threshold operation.
  - Clear the artificial ramp after the peak display.

Public controls:
  - None.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id FoldedTriangleShaper --agent
hise-cli builder set --module FoldedTriangleShaper --network folded_triangle_shaper --agent
hise-cli dsp add --module FoldedTriangleShaper --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module FoldedTriangleShaper --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module FoldedTriangleShaper --type math.add --id BipolarOffset --agent
hise-cli dsp set --module FoldedTriangleShaper --node BipolarOffset --param Value --range "-1,1" --agent
hise-cli dsp set --module FoldedTriangleShaper --node BipolarOffset --param Value --value -0.5 --agent
hise-cli dsp add --module FoldedTriangleShaper --type math.mul --id BipolarScale --agent
hise-cli dsp set --module FoldedTriangleShaper --node BipolarScale --param Value --range "0,2" --agent
hise-cli dsp set --module FoldedTriangleShaper --node BipolarScale --param Value --value 2 --agent
hise-cli dsp add --module FoldedTriangleShaper --type math.abs --id FoldShape --agent
hise-cli dsp add --module FoldedTriangleShaper --type core.peak --id OutputPeak --agent
hise-cli dsp add --module FoldedTriangleShaper --type math.clear --id SignalClear --agent
```
