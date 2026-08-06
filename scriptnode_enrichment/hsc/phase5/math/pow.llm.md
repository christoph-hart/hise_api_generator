---
id: math.pow.exponent-curve-shaper
node: math.pow
domain: scriptnode
category: dsp-network
title: Exponent curve shaper
summary: Uses math.pow to reshape a non-negative signal with an exponent transform.
useCase: Use this for unipolar curve bending when a power-law shape is needed.
difficulty: beginner
networkName: exponent_curve_shaper
moduleType: ScriptFX
moduleId: ExponentCurveShaper
tags:
  - exponent
  - curve
  - waveshaping
aliases:
  - power curve
  - exponent transform
relatedNodes:
  - math.pow
  - math.add
  - analyse.specs
  - math.clear
parameters:
  PowerShape.Value: Unused interface parameter; the example focuses on the fixed exponent transform.
---

scriptnode example: math.pow

Exponent curve shaper.
Use this to compare a non-negative known input with its power-law result.

Graph:
```text
exponent_curve_shaper
  SeedValue             math.add
  InputSpecs            analyse.specs
  PowerShape            math.pow
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `ExponentCurveShaper`
  Type: `ScriptFX`
  Network: `exponent_curve_shaper`
  Builder setup: add ScriptFX `ExponentCurveShaper`, then set its network.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - Keep inputs non-negative because fractional exponents can produce NaN for negative values.
  - This is a unipolar curve shaper.

Public controls:
  - None.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ExponentCurveShaper --agent
hise-cli builder set --module ExponentCurveShaper --network exponent_curve_shaper --agent
hise-cli dsp add --module ExponentCurveShaper --type math.add --id SeedValue --agent
hise-cli dsp set --module ExponentCurveShaper --node SeedValue --param Value --value 0.25 --agent
hise-cli dsp add --module ExponentCurveShaper --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ExponentCurveShaper --type math.pow --id PowerShape --agent
hise-cli dsp add --module ExponentCurveShaper --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ExponentCurveShaper --type math.clear --id SignalClear --agent
```
