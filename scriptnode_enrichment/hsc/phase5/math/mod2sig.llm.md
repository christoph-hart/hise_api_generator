---
id: math.mod2sig.unipolar-to-bipolar
node: math.mod2sig
domain: scriptnode
category: dsp-network
title: Unipolar to bipolar converter
summary: Uses math.mod2sig to map a 0..1 value into the -1..1 signal range.
useCase: Use this when a modulation value must drive bipolar signal processing.
difficulty: beginner
networkName: unipolar_to_bipolar
moduleType: ScriptFX
moduleId: UnipolarToBipolar
tags:
  - range-conversion
  - modulation
  - bipolar
aliases:
  - modulation to signal
  - unipolar to signal
relatedNodes:
  - math.mod2sig
  - math.add
  - analyse.specs
  - math.clear
parameters:
  RangeConverter.Value: Unused interface parameter; conversion is fixed.
---

scriptnode example: math.mod2sig

Unipolar to bipolar converter.
Use this to compare a known 0..1 value with its -1..1 converted result.

Graph:
```text
unipolar_to_bipolar
  SeedValue             math.add
  InputSpecs            analyse.specs
  RangeConverter        math.mod2sig
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `UnipolarToBipolar`
  Type: `ScriptFX`
  Network: `unipolar_to_bipolar`
  Builder setup: add ScriptFX `UnipolarToBipolar`, then set its network.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - Keep the seed inside 0..1.
  - `math.mod2sig` maps 0..1 into -1..1.

Public controls:
  - None.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id UnipolarToBipolar --agent
hise-cli builder set --module UnipolarToBipolar --network unipolar_to_bipolar --agent
hise-cli dsp add --module UnipolarToBipolar --type math.add --id SeedValue --agent
hise-cli dsp set --module UnipolarToBipolar --node SeedValue --param Value --value 0.25 --agent
hise-cli dsp add --module UnipolarToBipolar --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module UnipolarToBipolar --type math.mod2sig --id RangeConverter --agent
hise-cli dsp add --module UnipolarToBipolar --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module UnipolarToBipolar --type math.clear --id SignalClear --agent
```
