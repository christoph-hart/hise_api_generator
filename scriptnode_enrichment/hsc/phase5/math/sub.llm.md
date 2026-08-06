---
id: math.sub.dc-subtractor
node: math.sub
domain: scriptnode
category: dsp-network
title: DC subtractor
summary: Uses math.sub to remove a public raw scalar offset from a known test signal.
useCase: Use this to remove a known DC offset or shift a signal down before downstream processing.
difficulty: beginner
networkName: dc_subtractor
moduleType: ScriptFX
moduleId: DcSubtractor
tags:
  - arithmetic
  - dc-offset
  - subtraction
aliases:
  - scalar subtractor
  - DC remover
relatedNodes:
  - math.sub
  - math.add
  - analyse.specs
  - math.clear
parameters:
  Offset: Public scalar subtracted from every sample by OffsetSubtractor.Value.
  OffsetSubtractor.Value: Raw subtraction amount, demonstrated with a 0.2 default.
---

scriptnode example: math.sub

DC subtractor.
Use this to demonstrate removal of a constant scalar offset. A seeded test signal and analyser nodes make the subtraction visible.

Graph:
```text
dc_subtractor
  SeedValue             math.add
  InputSpecs            analyse.specs
  OffsetSubtractor      math.sub
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `DcSubtractor`
  Type: `ScriptFX`
  Network: `dc_subtractor`
  Builder setup: `add ScriptFX as "DcSubtractor"`, then set its network to `dc_subtractor`.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - Seed a non-zero signal before the input analyser.
  - `math.sub` removes a raw scalar offset from every sample.
  - Clear the artificial signal after the output analyser.

Public controls:
  - `Offset` -> `OffsetSubtractor.Value`, matched, range `0..0.5`, default `0.2`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DcSubtractor --agent
hise-cli builder set --module DcSubtractor --network dc_subtractor --agent
hise-cli dsp add --module DcSubtractor --type math.add --id SeedValue --agent
hise-cli dsp set --module DcSubtractor --node SeedValue --param Value --value 0.8 --agent
hise-cli dsp add --module DcSubtractor --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module DcSubtractor --type math.sub --id OffsetSubtractor --agent
hise-cli dsp set --module DcSubtractor --node OffsetSubtractor --param Value --range "0,0.5" --agent
hise-cli dsp set --module DcSubtractor --node OffsetSubtractor --param Value --value 0.2 --agent
hise-cli dsp add --module DcSubtractor --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module DcSubtractor --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module DcSubtractor --container dc_subtractor --id Offset --range "0,0.5" --default 0.2 --agent
hise-cli dsp connect --module DcSubtractor --source dc_subtractor --source-param Offset --target OffsetSubtractor --param Value --matched --agent
```
