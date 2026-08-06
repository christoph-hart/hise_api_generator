---
id: math.mod_inv.modulation-inverter
node: math.mod_inv
domain: scriptnode
category: dsp-network
title: Modulation inverter
summary: Uses math.mod_inv to complement a known 0..1 modulation value.
useCase: Use this for unipolar inversion around one-half.
difficulty: beginner
networkName: modulation_inverter
moduleType: ScriptFX
moduleId: ModulationInverter
tags:
  - inversion
  - modulation
  - complement
aliases:
  - modulation complement
  - one minus x
relatedNodes:
  - math.mod_inv
  - math.inv
  - math.add
  - analyse.specs
  - math.clear
parameters:
  InvertModulation.Value: Unused interface parameter; inversion is fixed.
---

scriptnode example: math.mod_inv

Modulation inverter.
Use this to show the `1 - x` complement of a known unipolar value.

Graph:
```text
modulation_inverter
  SeedValue             math.add
  InputSpecs            analyse.specs
  InvertModulation      math.mod_inv
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `ModulationInverter`
  Type: `ScriptFX`
  Network: `modulation_inverter`
  Builder setup: add ScriptFX `ModulationInverter`, then set its network.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - This flips a unipolar value around one-half.
  - Do not confuse it with `math.inv`, which negates bipolar signal polarity.

Public controls:
  - None.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ModulationInverter --agent
hise-cli builder set --module ModulationInverter --network modulation_inverter --agent
hise-cli dsp add --module ModulationInverter --type math.add --id SeedValue --agent
hise-cli dsp set --module ModulationInverter --node SeedValue --param Value --value 0.25 --agent
hise-cli dsp add --module ModulationInverter --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ModulationInverter --type math.mod_inv --id InvertModulation --agent
hise-cli dsp add --module ModulationInverter --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ModulationInverter --type math.clear --id SignalClear --agent
```
