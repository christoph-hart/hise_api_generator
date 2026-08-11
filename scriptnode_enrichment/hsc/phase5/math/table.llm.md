---
id: math.table.drawn-transfer-shaper
node: math.table
domain: scriptnode
category: dsp-network
title: Drawn transfer shaper
summary: Uses math.table with an external Table slot seeded from Interface onInit to draw a deterministic transfer curve.
useCase: Use this when a scriptnode network should read a user-editable or scripted curve as a lookup waveshaper.
difficulty: intermediate
networkName: drawn_transfer_shaper
moduleType: ScriptFX
moduleId: DrawnTransferShaper
tags:
  - table
  - lookup
  - waveshaper
  - external-data
aliases:
  - table lookup shaper
  - drawn transfer curve
relatedNodes:
  - math.table
  - core.ramp
  - core.peak
  - math.clear
parameters:
  TableLookup.Table: External Table slot index 0 initialized from Interface onInit.
  SlowRamp.PeriodTime: Slow scan period used to make the table curve visible.
---

scriptnode example: math.table

Drawn transfer shaper.
Use this to demonstrate `math.table` with deterministic external Table data instead of empty-table passthrough.

Graph:
```text
drawn_transfer_shaper
  SlowRamp              core.ramp
  TableLookup           math.table
  OutputPeak            core.peak
  SignalClear           math.clear
```

Host:
  Module: `DrawnTransferShaper`
  Type: `ScriptFX`
  Network: `drawn_transfer_shaper`
  Routing: default stereo
  Builder setup: `add ScriptFX as "DrawnTransferShaper"`, then set its network to `drawn_transfer_shaper`.

Support nodes:
  Required: `core.ramp`, `core.peak`, `math.clear`

Key rules:
  - Use external Table data index `0`; embedded complex data cannot be initialized from Interface script.
  - Initialize the Table in Interface `onInit` with `Synth.getTableProcessor("DrawnTransferShaper").getTable(0)`.
  - Keep lookup input in the 0..1 domain because `math.table` clamps the lookup range.

Public controls:
  - None. The public interaction is the external Table shape.

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DrawnTransferShaper --agent
hise-cli builder set --module DrawnTransferShaper --network drawn_transfer_shaper --agent
hise-cli dsp add --module DrawnTransferShaper --type core.ramp --id SlowRamp --agent
hise-cli dsp set --module DrawnTransferShaper --node SlowRamp --param PeriodTime --value 1000 --agent
hise-cli dsp add --module DrawnTransferShaper --type math.table --id TableLookup --agent
hise-cli dsp set-complex-data --module DrawnTransferShaper --node TableLookup --type Table --index 0 --agent
hise-cli dsp add --module DrawnTransferShaper --type core.peak --id OutputPeak --agent
hise-cli dsp add --module DrawnTransferShaper --type math.clear --id SignalClear --agent
hise-cli script set --module-id Interface --callback onInit --stdin --agent <<'HISESCRIPT'
Content.makeFrontInterface(600, 600);

const var tableProcessor = Synth.getTableProcessor("DrawnTransferShaper");
const var tableData = tableProcessor.getTable(0);

tableData.reset();
tableData.addTablePoint(0.5, 0.3);
tableData.setTablePoint(2, 1.0, 1.0, 0.2);
HISESCRIPT
```
