---
id: math.sqrt.root-curve-shaper
node: math.sqrt
domain: scriptnode
category: dsp-network
title: Root curve shaper
summary: Uses math.sqrt to apply a concave root transform to a non-negative signal.
useCase: Use this for a fast-rising unipolar curve shape.
difficulty: beginner
networkName: root_curve_shaper
moduleType: ScriptFX
moduleId: RootCurveShaper
tags:
  - square-root
  - curve
  - unipolar
aliases:
  - root transform
  - concave shaper
relatedNodes:
  - math.sqrt
  - math.add
  - analyse.specs
  - math.clear
parameters:
  RootShape.Value: Unused interface parameter; the node always computes square root.
---

scriptnode example: math.sqrt

Root curve shaper.
Use this to compare a non-negative known input with its fast-rising square-root result.

Graph:
```text
root_curve_shaper
  SeedValue             math.add
  InputSpecs            analyse.specs
  RootShape             math.sqrt
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `RootCurveShaper`
  Type: `ScriptFX`
  Network: `root_curve_shaper`
  Builder setup: add ScriptFX `RootCurveShaper`, then set its network.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - Keep inputs non-negative because negative values produce NaN.
  - This is a unipolar curve shaper, not a bipolar processor.

Public controls:
  - None.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id RootCurveShaper --agent
hise-cli builder set --module RootCurveShaper --network root_curve_shaper --agent
hise-cli dsp add --module RootCurveShaper --type math.add --id SeedValue --agent
hise-cli dsp set --module RootCurveShaper --node SeedValue --param Value --value 0.25 --agent
hise-cli dsp add --module RootCurveShaper --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module RootCurveShaper --type math.sqrt --id RootShape --agent
hise-cli dsp add --module RootCurveShaper --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module RootCurveShaper --type math.clear --id SignalClear --agent
```
