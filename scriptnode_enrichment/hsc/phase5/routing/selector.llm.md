---
id: routing.selector.cab-mic-pair-selector
node: routing.selector
domain: scriptnode
category: dsp-network
title: Cab mic pair selector
summary: Uses routing.selector to choose one stereo pair from a four-channel buffer and route it into a cabinet tone chain.
useCase: Use this when you need a public control that selects which stereo pair in a multichannel buffer feeds downstream processing.
difficulty: intermediate
networkName: cab_mic_selector
moduleType: ScriptFX
moduleId: CabMicSelector
tags:
  - channel-routing
  - stereo-pair-selection
  - multichannel-buffer
  - cabinet-chain
  - selector
aliases:
  - mic pair selector
  - stereo pair routing
  - dynamic channel selector
  - multichannel pair selection
  - route selected pair to front
relatedNodes:
  - routing.selector
  - container.multi
  - container.chain
  - filters.svf_eq
  - jdsp.jcompressor
  - core.gain
parameters:
  MicPosition: Public raw channel-offset control connected to MicPairSelector.ChannelIndex.
  MicPairSelector.ChannelIndex: Selects the source stereo pair offset, using 0 for channels 0-1 and 2 for channels 2-3.
  MicPairSelector.NumChannels: Fixed to 2 so each selection copies one stereo pair.
  MicPairSelector.SelectOutput: Left at default so selected input channels are copied to the front of the buffer.
  MicPairSelector.ClearOtherChannels: Left enabled so non-selected channels are cleared.
---

scriptnode example: routing.selector

Cab mic pair selector.
Use this to select one stereo mic pair from a four-channel buffer and send only that pair into a cabinet tone-shaping chain.

Graph:
```text
cab_mic_selector
  MicPairSelector        routing.selector
  PairSplit             container.multi
    SelectedPair        container.chain
      CabToneEQ         filters.svf_eq
      CabGlueComp       jdsp.jcompressor
      CabMakeupGain     core.gain
    UnusedPair          container.chain
```

Host:
  Module: `CabMicSelector`
  Type: `ScriptFX`
  Network: `cab_mic_selector`
  Routing: ScriptFX uses four internal channels; Master Chain folds channels `[0,1,0,1]` back to stereo output.
  Builder setup:
    - `add ScriptFX as "CabMicSelector"`
    - `set CabMicSelector.network "cab_mic_selector"`
    - `set "Master Chain".routing [0, 1, 0, 1]`
    - `set CabMicSelector.routing [0, 1, 2, 3]`

Support nodes:
  Required: `container.multi`, `container.chain`, `filters.svf_eq`, `jdsp.jcompressor`, `core.gain`

Key rules:
  - Use four ScriptFX channels so `routing.selector` can choose between two stereo pairs.
  - Set `MicPairSelector.NumChannels` to `2` so the selector copies a stereo pair, not a single channel.
  - Use raw channel offsets for `MicPosition`: `0` selects channels 0-1 and `2` selects channels 2-3.
  - Narrow `ChannelIndex` to `0..2` with step `2` before connecting the public control with `matched`.
  - Leave `SelectOutput` at default so the selected input pair is copied to the front of the buffer.
  - Leave `ClearOtherChannels` enabled so non-selected channels are zeroed.
  - Use `container.multi` after `routing.selector` so the FX chain only processes the selected pair on channels 0-1.

Public controls:
  - `MicPosition` -> `MicPairSelector.ChannelIndex`, matched, `0..2`, step `2`, default `2`

HISE CLI build commands:
```bash
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id CabMicSelector --agent
hise-cli builder set --module CabMicSelector --network cab_mic_selector --agent
hise-cli builder set --module "Master Chain" --routing "[0,1,0,1]" --agent
hise-cli builder set --module CabMicSelector --routing "[0,1,2,3]" --agent

hise-cli dsp add --module CabMicSelector --type routing.selector --id MicPairSelector --agent
hise-cli dsp set --module CabMicSelector --node MicPairSelector --param NumChannels --value 2 --agent
hise-cli dsp set --module CabMicSelector --node MicPairSelector --param ChannelIndex --range "0,2" --stepSize 2 --agent

hise-cli dsp add --module CabMicSelector --type container.multi --id PairSplit --agent
hise-cli dsp add --module CabMicSelector --type container.chain --id SelectedPair --parent PairSplit --agent
hise-cli dsp add --module CabMicSelector --type container.chain --id UnusedPair --parent PairSplit --agent

hise-cli dsp add --module CabMicSelector --type filters.svf_eq --id CabToneEQ --parent SelectedPair --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param Mode --value 4 --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param Frequency --value 3500 --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param Q --value 1.2 --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param Gain --value -3 --agent

hise-cli dsp add --module CabMicSelector --type jdsp.jcompressor --id CabGlueComp --parent SelectedPair --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param Treshold --value -18 --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param Ratio --value 3 --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param Attack --value 12 --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param Release --value 120 --agent

hise-cli dsp add --module CabMicSelector --type core.gain --id CabMakeupGain --parent SelectedPair --agent
hise-cli dsp set --module CabMicSelector --node CabMakeupGain --param Gain --range "-24,6" --stepSize 0.1 --agent
hise-cli dsp set --module CabMicSelector --node CabMakeupGain --param Gain --value 3 --agent

hise-cli dsp create_parameter --module CabMicSelector --container cab_mic_selector --id MicPosition --range "0,2" --default 2 --stepSize 2 --agent
hise-cli dsp connect --module CabMicSelector --source cab_mic_selector --source-param MicPosition --target MicPairSelector --param ChannelIndex --matched --agent

hise-cli dsp set --module CabMicSelector --node MicPairSelector --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module CabMicSelector --node MicPairSelector --param Comment --value "**Mic pair selector** - Dynamically routes one of two input stereo pairs into a subsequent FX chain." --agent
hise-cli dsp set --module CabMicSelector --node PairSplit --param Comment --value "**Channel isolation** - Splits the 4-channel buffer into stereo slices so the FX chain only processes the selected pair on channels 0-1." --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module CabMicSelector --node UnusedPair --param Folded --value true --agent
hise-cli dsp set --module CabMicSelector --node CabToneEQ --param Folded --value true --agent
hise-cli dsp set --module CabMicSelector --node CabGlueComp --param Folded --value true --agent
hise-cli dsp set --module CabMicSelector --node CabMakeupGain --param Folded --value true --agent
```
