---
id: container.branch.selectable-waveshaper-modes
node: container.branch
domain: scriptnode
category: dsp-network
title: "Selectable Waveshaper Modes"
summary: "A container that processes only the child selected by its Index parameter."
useCase: "Demonstrate that `container.branch` immediately dispatches audio to exactly one indexed child while leaving the other prepared children idle."
difficulty: intermediate
networkName: selectable_waveshaper
moduleType: ScriptFX
moduleId: SelectableWaveshaper
tags:
  - container
  - branch
  - routing
  - parallel-processing
aliases:
  - selectable waveshaper modes
  - branch container
relatedNodes:
  - container.branch
  - math.expr
parameters:
  Mode: "Mode -> ShapeModes.Index matched"
  Target: "Target range before connection: [0, 2], step 1"
  Macro: "Macro range: [0, 2], step 1, labels Tanh, HISE Saturation, Sine Fold"
  Default:: "Default: 0"
---

scriptnode example: container.branch

Selectable Waveshaper Modes.

Demonstrate that `container.branch` immediately dispatches audio to exactly one indexed child while leaving the other prepared children idle.

Graph:
```text
selectable_waveshaper
  ShapeModes             container.branch
    TanhShape            math.expr
    HiseSaturation       math.expr
    SineFold             math.expr
```

Host:
  Module: SelectableWaveshaper
  Network: selectable_waveshaper
  Host context: Script FX
  Required channels: default stereo
  Module routing: default stereo
  Master routing: default stereo
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "SelectableWaveshaper"`, then set its network to `selectable_waveshaper`.

Support nodes:
  Required: math.expr
  Three `math.expr` instances implement the distinct tanh, HISE saturation, and sine-folding transfer functions that the branch selects between.

Key rules:
  - Before ShapeModes: Only the selected prepared child processes audio, and Index switches immediately without a crossfade.
  - Before the expression values: Lock each amount so Mode compares transfer functions rather than unrelated gain settings.
  - Expecting click-free index switching: Branch switches immediately with no crossfade. Stateful children (filters, delays) may produce clicks when switched. The softbypass_switch templates combine soft_bypass containers with control.xfader for smooth transitions.
  - Using chained soft_bypass nodes instead of branch: Chaining multiple soft_bypass containers can produce audio bumps. Branch avoids that chained topology, but its own Index changes are immediate and do not crossfade.

Public controls:
  - Mode -> ShapeModes.Index matched
  - Target range before connection: [0, 2], step 1
  - Macro range: [0, 2], step 1, labels Tanh, HISE Saturation, Sine Fold
  - Default: 0

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SelectableWaveshaper --agent
hise-cli builder set --module SelectableWaveshaper --network selectable_waveshaper --agent

hise-cli dsp add --module SelectableWaveshaper --type container.branch --id ShapeModes --agent
hise-cli dsp add --module SelectableWaveshaper --type math.expr --id TanhShape --parent ShapeModes --agent
hise-cli dsp add --module SelectableWaveshaper --type math.expr --id HiseSaturation --parent ShapeModes --agent
hise-cli dsp add --module SelectableWaveshaper --type math.expr --id SineFold --parent ShapeModes --agent

hise-cli dsp set --module SelectableWaveshaper --node TanhShape --param Code --value '"Math.tanh(input * (1.0f + value * 5.0f))"' --agent
hise-cli dsp set --module SelectableWaveshaper --node TanhShape --param Value --value 0.5 --agent
hise-cli dsp set --module SelectableWaveshaper --node HiseSaturation --param Code --value '"(1.0f + value / (1.0f - value)) * input / (1.0f + value / (1.0f - value) * Math.abs(input))"' --agent
hise-cli dsp set --module SelectableWaveshaper --node HiseSaturation --param Value --value 0.75 --agent
hise-cli dsp set --module SelectableWaveshaper --node SineFold --param Code --value '"Math.sin(input * (1.0f + value * 8.0f))"' --agent
hise-cli dsp set --module SelectableWaveshaper --node SineFold --param Value --value 0.5 --agent
hise-cli dsp set --module SelectableWaveshaper --node ShapeModes --param Index --range "0,2" --stepSize 1 --agent

hise-cli dsp create_parameter --module SelectableWaveshaper --container selectable_waveshaper --id Mode --range "0,2" --default 0 --stepSize 1 --agent
hise-cli dsp connect --module SelectableWaveshaper --source selectable_waveshaper --source-param Mode --target ShapeModes --param Index --matched --agent
# Expose Index so the root Mode cable is visible on the inner container.
hise-cli dsp set --module SelectableWaveshaper --node ShapeModes --param ShowParameters --value true --agent

hise-cli dsp set --module SelectableWaveshaper --node ShapeModes --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module SelectableWaveshaper --node ShapeModes --param Comment --value '"**Selectable waveshaper** - Only the child selected by Mode processes audio; switching is immediate without a crossfade."' --agent
hise-cli dsp set --module SelectableWaveshaper --node TanhShape --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module SelectableWaveshaper --node TanhShape --param Comment --value '"Tanh transfer with a locked amount for a consistent algorithm comparison."' --agent
hise-cli dsp set --module SelectableWaveshaper --node HiseSaturation --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module SelectableWaveshaper --node HiseSaturation --param Comment --value '"HISE-style rational saturation with a locked amount."' --agent
hise-cli dsp set --module SelectableWaveshaper --node SineFold --param NodeColour --value 0xFF8C6D55 --agent
hise-cli dsp set --module SelectableWaveshaper --node SineFold --param Comment --value '"Sine folding transfer with a locked amount."' --agent
```

