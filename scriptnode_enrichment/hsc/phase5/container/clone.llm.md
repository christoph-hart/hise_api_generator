---
id: container.clone.dynamic-saw-unison
node: container.clone
domain: scriptnode
category: dsp-network
title: "Dynamic Saw Unison"
summary: "An array of identical child node chains with configurable processing modes."
useCase: "Demonstrate how `container.clone` runs identical child chains in parallel while clone-aware control nodes differentiate pitch, stereo position, and gain per active clone."
difficulty: intermediate
networkName: dynamic_saw_unison
moduleType: ScriptFX
moduleId: DynamicSawUnison
tags:
  - container
  - clone
aliases:
  - dynamic saw unison
  - clone container
relatedNodes:
  - container.clone
  - control.clone_cable
  - core.oscillator
  - jdsp.jpanner
parameters:
  NumClones: "NumClones -> UnisonLayers.NumClones matched and every clone cable NumClones matched"
  Target: "Target range before connection: [1, 8], step 1"
  Macro: "Macro range: [1, 8], step 1"
  Default:: "Default: 4"
  Spread: "Spread -> PitchSpread.Value and PanSpread.Value matched"
  Target: "Target range before connection: [0, 1]"
  Macro: "Macro range: [0, 1]"
  Default:: "Default: 0.5"
---

scriptnode example: container.clone

Dynamic Saw Unison.

Demonstrate how `container.clone` runs identical child chains in parallel while clone-aware control nodes differentiate pitch, stereo position, and gain per active clone.

Graph:
```text
dynamic_saw_unison
  CloneControls          container.offline
    PitchSpread          control.clone_cable
    PanSpread            control.clone_cable
    GainCompensation     control.clone_cable
  UnisonLayers           container.clone
    UnisonVoice          container.chain
      SawLayer           core.oscillator
      LayerPan           jdsp.jpanner
```

Host:
  Module: DynamicSawUnison
  Network: dynamic_saw_unison
  Host context: Script FX
  Required channels: default stereo
  Module routing: default stereo
  Master routing: default stereo
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "DynamicSawUnison"`, then set its network to `dynamic_saw_unison`.

Support nodes:
  Required: control.clone_cable, core.oscillator, jdsp.jpanner
  An offline container presents the control-only nodes as one horizontal strip. Separate `control.clone_cable` instances distribute the shared Spread value to each clone's oscillator frequency ratio and panner position, and a Ducker-mode instance compensates level as clone count changes; `core.oscillator` generates the saw layer in every cloned chain; and `jdsp.jpanner` places each generated layer at its assigned stereo position.

Key rules:
  - Before setting UnisonLayers.NumClones to 8: Setting NumClones through the CLI silently rebuilds the first completed child into eight physical clone chains.
  - Before public parameters: NumClones must be the first macro and use the same range on the clone container and all clone cables.
  - Before UnisonLayers: Parallel mode supplies silence to each clone generator and sums their outputs without multiplying input audio.
  - Before CloneControls: The offline horizontal container groups control-only nodes without processing audio.
  - Before clone cables: Clone-aware cables provide per-layer frequency ratio, pan, and gain values; ordinary clone parameters remain synchronized.
  - All clones receive identical parameters: Clone parameters are synchronised across all clones. For per-clone differentiation (detuning, panning, harmonic frequencies), use the dedicated clone control nodes to distribute different values.
  - Clone inside a frame-based container: Clone does not support frame-based processing. Place frame containers inside the cloned child chain if per-sample processing is needed.
  - NumClones not set as first macro control: If NumClones is not the first macro parameter, or if connected nodes have mismatched ranges, the clone container may fail silently or produce compilation errors.

Public controls:
  - NumClones -> UnisonLayers.NumClones matched and every clone cable NumClones matched
  - Target range before connection: [1, 8], step 1
  - Macro range: [1, 8], step 1
  - Default: 4
  - Spread -> PitchSpread.Value and PanSpread.Value matched
  - Target range before connection: [0, 1]
  - Macro range: [0, 1]
  - Default: 0.5

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id DynamicSawUnison --agent
hise-cli builder set --module DynamicSawUnison --network dynamic_saw_unison --agent

hise-cli dsp add --module DynamicSawUnison --type container.offline --id CloneControls --agent
hise-cli dsp set --module DynamicSawUnison --node CloneControls --param IsVertical --value false --agent
hise-cli dsp add --module DynamicSawUnison --type control.clone_cable --id PitchSpread --parent CloneControls --agent
hise-cli dsp add --module DynamicSawUnison --type control.clone_cable --id PanSpread --parent CloneControls --agent
hise-cli dsp add --module DynamicSawUnison --type control.clone_cable --id GainCompensation --parent CloneControls --agent
hise-cli dsp add --module DynamicSawUnison --type container.clone --id UnisonLayers --agent
hise-cli dsp rename --module DynamicSawUnison --node clone_child --id UnisonVoice --agent
hise-cli dsp add --module DynamicSawUnison --type core.oscillator --id SawLayer --parent UnisonVoice --agent
hise-cli dsp add --module DynamicSawUnison --type jdsp.jpanner --id LayerPan --parent UnisonVoice --agent

hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param SplitSignal --value 1 --agent
hise-cli dsp set --module DynamicSawUnison --node PitchSpread --param NumClones --range "1,8" --stepSize 1 --agent
hise-cli dsp set --module DynamicSawUnison --node PanSpread --param NumClones --range "1,8" --stepSize 1 --agent
hise-cli dsp set --module DynamicSawUnison --node GainCompensation --param NumClones --range "1,8" --stepSize 1 --agent
hise-cli dsp set --module DynamicSawUnison --node GainCompensation --param Mode --value '"Ducker"' --agent
hise-cli dsp set --module DynamicSawUnison --node SawLayer --param Mode --value 1 --agent
hise-cli dsp set --module DynamicSawUnison --node SawLayer --param 'Freq Ratio' --range "0.5,2" --stepSize 0 --middlePosition 1 --agent
hise-cli dsp set --module DynamicSawUnison --node LayerPan --param Rule --value 2 --agent

hise-cli dsp set --module DynamicSawUnison --node SawLayer --param NodeColour --value 0xFF5F7894 --agent
hise-cli dsp set --module DynamicSawUnison --node LayerPan --param NodeColour --value 0xFF5F7894 --agent

# Setting NumClones through the CLI silently rebuilds the first completed child into eight physical clone chains.
hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param NumClones --range "1,8" --stepSize 1 --agent
hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param NumClones --value 8 --agent

hise-cli dsp create_parameter --module DynamicSawUnison --container dynamic_saw_unison --id NumClones --range "1,8" --default 4 --stepSize 1 --agent
hise-cli dsp create_parameter --module DynamicSawUnison --container dynamic_saw_unison --id Spread --range "0,1" --default 0.5 --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param NumClones --target UnisonLayers --param NumClones --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param NumClones --target PitchSpread --param NumClones --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param NumClones --target PanSpread --param NumClones --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param NumClones --target GainCompensation --param NumClones --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param Spread --target PitchSpread --param Value --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source dynamic_saw_unison --source-param Spread --target PanSpread --param Value --matched --agent
hise-cli dsp connect --module DynamicSawUnison --source PitchSpread --target SawLayer --param 'Freq Ratio' --agent
hise-cli dsp connect --module DynamicSawUnison --source PanSpread --target LayerPan --param Pan --agent
hise-cli dsp connect --module DynamicSawUnison --source GainCompensation --target SawLayer --param Gain --agent
# Expose NumClones so its root cable is visible on the clone container.
hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param ShowParameters --value true --agent

hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module DynamicSawUnison --node UnisonLayers --param Comment --value '"**Dynamic saw unison** - Parallel clones generate from silence and spread oscillator ratios from half-speed to double-speed."' --agent
hise-cli dsp set --module DynamicSawUnison --node CloneControls --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DynamicSawUnison --node CloneControls --param Comment --value '"Offline horizontal control strip: clone cables update targets without processing the audio buffer."' --agent
hise-cli dsp set --module DynamicSawUnison --node PitchSpread --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DynamicSawUnison --node PitchSpread --param Comment --value '"Spread distributes octave ratios from 0.5 to 2 across active clones."' --agent
hise-cli dsp set --module DynamicSawUnison --node PanSpread --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DynamicSawUnison --node PanSpread --param Comment --value '"Spread distributes stereo positions across active clones."' --agent
hise-cli dsp set --module DynamicSawUnison --node GainCompensation --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module DynamicSawUnison --node GainCompensation --param Comment --value '"Ducker mode scales each oscillator by the reciprocal clone count."' --agent
```

