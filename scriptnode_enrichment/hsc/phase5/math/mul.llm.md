---
id: math.mul.scalar-gain-multiplier
node: math.mul
domain: scriptnode
category: dsp-network
title: Scalar gain multiplier
summary: Uses math.mul to apply public raw linear gain scaling to a known test signal.
useCase: Use this for direct scalar amplitude scaling when decibel gain and smoothing are not required.
difficulty: beginner
networkName: scalar_gain_multiplier
moduleType: ScriptFX
moduleId: ScalarGainMultiplier
tags:
  - arithmetic
  - gain
  - scalar
aliases:
  - raw gain multiplier
  - linear gain
relatedNodes:
  - math.mul
  - math.add
  - analyse.specs
  - math.clear
parameters:
  Multiplier: Public scalar multiplier connected to GainScale.Value.
  GainScale.Value: Raw linear multiplier; 1.0 passes the signal unchanged.
---

scriptnode example: math.mul

Scalar gain multiplier.
Use this to demonstrate direct linear signal scaling. The seeded test signal makes the input and output analyser values easy to compare.

Graph:
```text
scalar_gain_multiplier
  SeedValue             math.add
  InputSpecs            analyse.specs
  GainScale             math.mul
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `ScalarGainMultiplier`
  Type: `ScriptFX`
  Network: `scalar_gain_multiplier`
  Builder setup: `add ScriptFX as "ScalarGainMultiplier"`, then set its network to `scalar_gain_multiplier`.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - Seed a non-zero signal before the input analyser.
  - `math.mul` is raw linear scaling; use `core.gain` for decibel-scaled control.
  - Clear the artificial signal after the output analyser.

Public controls:
  - `Multiplier` -> `GainScale.Value`, matched, range `0..1`, default `0.5`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ScalarGainMultiplier --agent
hise-cli builder set --module ScalarGainMultiplier --network scalar_gain_multiplier --agent
hise-cli dsp add --module ScalarGainMultiplier --type math.add --id SeedValue --agent
hise-cli dsp set --module ScalarGainMultiplier --node SeedValue --param Value --value 0.8 --agent
hise-cli dsp add --module ScalarGainMultiplier --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ScalarGainMultiplier --type math.mul --id GainScale --agent
hise-cli dsp set --module ScalarGainMultiplier --node GainScale --param Value --range "0,1" --agent
hise-cli dsp set --module ScalarGainMultiplier --node GainScale --param Value --value 0.5 --agent
hise-cli dsp add --module ScalarGainMultiplier --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ScalarGainMultiplier --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module ScalarGainMultiplier --container scalar_gain_multiplier --id Multiplier --range "0,1" --default 0.5 --agent
hise-cli dsp connect --module ScalarGainMultiplier --source scalar_gain_multiplier --source-param Multiplier --target GainScale --param Value --matched --agent
```
