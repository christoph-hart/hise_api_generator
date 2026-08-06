---
id: math.square.squaring-curve-shaper
node: math.square
domain: scriptnode
category: dsp-network
title: Squaring curve shaper
summary: Uses math.square to apply a fixed x*x transform to a known signal.
useCase: Use this for a simple non-negative quadratic waveshaping step.
difficulty: beginner
networkName: squaring_curve_shaper
moduleType: ScriptFX
moduleId: SquaringCurveShaper
tags:
  - quadratic
  - waveshaping
  - arithmetic
aliases:
  - square transform
  - x squared
relatedNodes:
  - math.square
  - math.add
  - analyse.specs
  - math.clear
parameters:
  SquareShape.Value: Unused interface parameter; the node always computes input squared.
---

scriptnode example: math.square

Squaring curve shaper.
Use this to compare a known input with its fixed non-negative x*x result.

Graph:
```text
squaring_curve_shaper
  SeedValue             math.add
  InputSpecs            analyse.specs
  SquareShape           math.square
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `SquaringCurveShaper`
  Type: `ScriptFX`
  Network: `squaring_curve_shaper`
  Builder setup: add ScriptFX `SquaringCurveShaper`, then set its network.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - The Value parameter has no effect on processing.
  - The transform forces both positive and negative inputs non-negative.

Public controls:
  - None.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SquaringCurveShaper --agent
hise-cli builder set --module SquaringCurveShaper --network squaring_curve_shaper --agent
hise-cli dsp add --module SquaringCurveShaper --type math.add --id SeedValue --agent
hise-cli dsp set --module SquaringCurveShaper --node SeedValue --param Value --value 0.5 --agent
hise-cli dsp add --module SquaringCurveShaper --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module SquaringCurveShaper --type math.square --id SquareShape --agent
hise-cli dsp add --module SquaringCurveShaper --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module SquaringCurveShaper --type math.clear --id SignalClear --agent
```
