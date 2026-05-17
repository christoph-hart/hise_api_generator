---
id: dynamics.gate.noise-layer-gate
node: dynamics.gate
domain: scriptnode
category: dsp-network
title: Noise layer gate from split signal
summary: Uses dynamics.gate as an analysis branch to open a generated noise texture while dry audio passes unchanged.
useCase: Use this when you need an input-driven gate control signal that modulates a separate texture or effect branch.
difficulty: intermediate
networkName: noise_layer_gate
moduleType: ScriptFX
moduleId: NoiseLayerGate
tags:
  - gate
  - noise-layer
  - split-routing
  - modulation-output
  - dry-passthrough
aliases:
  - noise gate texture
  - gated noise layer
  - gate controlled branch
  - dry passthrough gate
  - gate modulation to gain
relatedNodes:
  - dynamics.gate
  - container.split
  - container.chain
  - math.clear
  - core.oscillator
  - filters.svf_eq
  - core.gain
parameters:
  GateThreshold: Controls when SelfGate opens from the duplicate analysis branch.
  GateRelease: Controls the audible release envelope of the texture layer.
  GateDepth: Controls gate ratio/depth on SelfGate.
  NoiseGain.Gain: Uses a reversed 0..-100 range because dynamics.gate outputs gain-reduction amount.
---

scriptnode example: dynamics.gate

Noise layer gate from split signal.
Use this to derive a gate control signal from the input while keeping dry audio untouched, then use the gate output to open a generated noise texture on a separate branch.

Graph:
```text
noise_layer_gate
  TextureSplit          container.split
    DryPath             container.chain
    GateControlPath     container.chain
      SelfGate          dynamics.gate
      ControlClear      math.clear
    NoisePath           container.chain
      NoiseClear        math.clear
      NoiseSource       core.oscillator
      NoiseFilter       filters.svf_eq
      NoiseGain         core.gain
```

Host:
  Module: `NoiseLayerGate`
  Type: `ScriptFX`
  Network: `noise_layer_gate`
  Routing: default stereo
  Builder setup:
    - `add ScriptFX as "NoiseLayerGate"`
    - `set NoiseLayerGate.network "noise_layer_gate"`

Support nodes:
  Required: `container.split`, `core.gain`, `core.oscillator`
  Optional: `container.fix16_block`, `filters.svf_eq`

Key rules:
  - Use `container.split` so dry audio, gate analysis, and generated texture stay on separate branches.
  - Keep the dry path separate because `dynamics.gate` has no `ProcessSignal` switch for analysis-only operation.
  - Run `SelfGate` on a duplicate input branch, then clear that branch with `ControlClear` so it does not add gated duplicate audio to the output.
  - Clear inherited split audio in `NoisePath` before adding `NoiseSource`, otherwise the texture branch doubles the dry signal.
  - `dynamics.gate` outputs gain-reduction amount, not open-gate activity; reverse `NoiseGain.Gain` to `0..-100` before connecting `SelfGate`.
  - Set `NoiseGain.Smoothing` to `0` so the audible texture envelope follows `SelfGate.Release` instead of an added gain smoothing stage.
  - Use `matched` for root controls whose ranges mirror gate parameters, but connect `SelfGate` to `NoiseGain.Gain` without `matched` because the target range is intentionally reversed.

Public controls:
  - `GateThreshold` -> `SelfGate.Threshhold`, matched, `-48..-18`, default `-30`
  - `GateRelease` -> `SelfGate.Release`, matched, `20..160`, default `80`
  - `GateDepth` -> `SelfGate.Ratio`, matched, `4..16`, default `10`

HISE CLI build commands:
```bash
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id NoiseLayerGate --agent
hise-cli builder set --module NoiseLayerGate --network noise_layer_gate --agent

hise-cli dsp add --module NoiseLayerGate --type container.split --id TextureSplit --agent
hise-cli dsp add --module NoiseLayerGate --type container.chain --id DryPath --parent TextureSplit --agent
hise-cli dsp add --module NoiseLayerGate --type container.chain --id GateControlPath --parent TextureSplit --agent
hise-cli dsp add --module NoiseLayerGate --type dynamics.gate --id SelfGate --parent GateControlPath --agent
hise-cli dsp add --module NoiseLayerGate --type math.clear --id ControlClear --parent GateControlPath --agent
hise-cli dsp add --module NoiseLayerGate --type container.chain --id NoisePath --parent TextureSplit --agent
hise-cli dsp add --module NoiseLayerGate --type math.clear --id NoiseClear --parent NoisePath --agent
hise-cli dsp add --module NoiseLayerGate --type core.oscillator --id NoiseSource --parent NoisePath --agent
hise-cli dsp add --module NoiseLayerGate --type filters.svf_eq --id NoiseFilter --parent NoisePath --agent
hise-cli dsp add --module NoiseLayerGate --type core.gain --id NoiseGain --parent NoisePath --agent

hise-cli dsp set --module NoiseLayerGate --node NoiseSource --param Mode --value 4 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseSource --param Gain --value 0.25 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseFilter --param Mode --value 1 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseFilter --param Frequency --value 2500 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseFilter --param Q --value 0.8 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseGain --param Gain --range "0,-100" --stepSize 0.1 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseGain --param Smoothing --value 0 --agent

hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Threshhold --range "-48,-18" --stepSize 0.1 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Threshhold --value -30 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Release --range "20,160" --stepSize 0.1 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Release --value 80 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Ratio --range "4,16" --stepSize 0.1 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Ratio --value 10 --agent

hise-cli dsp create_parameter --module NoiseLayerGate --container noise_layer_gate --id GateThreshold --range "-48,-18" --default -30 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module NoiseLayerGate --container noise_layer_gate --id GateRelease --range "20,160" --default 80 --stepSize 0.1 --agent
hise-cli dsp create_parameter --module NoiseLayerGate --container noise_layer_gate --id GateDepth --range "4,16" --default 10 --stepSize 0.1 --agent
hise-cli dsp connect --module NoiseLayerGate --source noise_layer_gate --source-param GateThreshold --target SelfGate --param Threshhold --matched --agent
hise-cli dsp connect --module NoiseLayerGate --source noise_layer_gate --source-param GateRelease --target SelfGate --param Release --matched --agent
hise-cli dsp connect --module NoiseLayerGate --source noise_layer_gate --source-param GateDepth --target SelfGate --param Ratio --matched --agent
hise-cli dsp connect --module NoiseLayerGate --source SelfGate --target NoiseGain --param Gain --agent

hise-cli dsp set --module NoiseLayerGate --node SelfGate --param NodeColour --value 0xFFE67E22 --agent
hise-cli dsp set --module NoiseLayerGate --node SelfGate --param Comment --value '"**Self-keyed gate** - This duplicate input branch drives the gate modulation while the original dry branch stays untouched."' --agent
hise-cli dsp set --module NoiseLayerGate --node TextureSplit --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node TextureSplit --param Comment --value '"Texture split keeps the dry source and control branch separate."' --agent
hise-cli dsp set --module NoiseLayerGate --node GateControlPath --param Comment --value '"Control branch only. SelfGate analyses a dry copy and ControlClear removes duplicate audio."' --agent
hise-cli dsp set --module NoiseLayerGate --node ControlClear --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node ControlClear --param Comment --value '"Clear the gated duplicate so only the dry branch reaches the output."' --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseClear --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseClear --param Comment --value '"Clear inherited signal before adding the synthetic noise layer."' --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseSource --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseSource --param Comment --value '"Oscillator noise keeps the example compact."' --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseFilter --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseGain --param NodeColour --value 0xFF8F7766 --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseGain --param Comment --value '"Reversed target range maps gate reduction to open gate texture gain."' --agent
hise-cli dsp set --module NoiseLayerGate --node DryPath --param Folded --value true --agent
hise-cli dsp set --module NoiseLayerGate --node ControlClear --param Folded --value true --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseClear --param Folded --value true --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseSource --param Folded --value true --agent
hise-cli dsp set --module NoiseLayerGate --node NoiseFilter --param Folded --value true --agent
```
