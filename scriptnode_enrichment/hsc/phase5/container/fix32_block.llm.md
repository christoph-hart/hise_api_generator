---
id: container.fix32_block.sidechain-dynamic-mid-cut
node: container.fix32_block
domain: scriptnode
category: dsp-network
title: "Sidechain Dynamic Mid Cut"
summary: "Splits the audio buffer into chunks of 32 samples for higher modulation update rates."
useCase: "Demonstrate why `container.fix32_block` is a practical general-purpose cadence for envelope-followed dynamic EQ: responsive enough for level tracking while avoiding the iteration cost reserved for pitch modulation and very fast envelopes."
difficulty: beginner
networkName: sidechain_dynamic_mid_cut
moduleType: ScriptFX
moduleId: SidechainDynamicMidCut
tags:
  - container
  - fix32
  - block
  - block-size
  - processing-context
aliases:
  - sidechain dynamic mid cut
  - fix32 block container
relatedNodes:
  - container.fix32_block
  - container.sidechain
  - container.multi
  - container.chain
  - container.no_midi
  - core.oscillator
  - dynamics.envelope_follower
  - control.pma_unscaled
  - filters.svf_eq
parameters:
  MaxCut: "MaxCut -> CutDepthPMA.Value raw unscaled connection"
  Macro: "Macro range: [-18, 0] dB"
  Default:: "Default: -9 dB"
---

scriptnode example: container.fix32_block

Sidechain Dynamic Mid Cut.

Demonstrate why `container.fix32_block` is a practical general-purpose cadence for envelope-followed dynamic EQ: responsive enough for level tracking while avoiding the iteration cost reserved for pitch modulation and very fast envelopes.

Graph:
```text
sidechain_dynamic_mid_cut
  ThirtyTwoSampleDucker  container.fix32_block
    InternalSidechain    container.sidechain
      ChannelSlices      container.multi
        MainAudio        container.chain
        KeyDetector      container.no_midi
          KeyOscillator  core.oscillator
          KeyFollower    dynamics.envelope_follower
          CutDepthPMA    control.pma_unscaled
      DynamicMidEQ       filters.svf_eq
```

Host:
  Module: SidechainDynamicMidCut
  Network: sidechain_dynamic_mid_cut
  Host context: Script FX
  Required channels: default stereo externally; four channels inside InternalSidechain
  Module routing: default stereo
  Master routing: default stereo
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "SidechainDynamicMidCut"`, then set its network to `sidechain_dynamic_mid_cut`.

Support nodes:
  Required: container.sidechain, container.multi, container.chain, container.no_midi, core.oscillator, dynamics.envelope_follower, control.pma_unscaled, filters.svf_eq
  `container.sidechain` creates an internal auxiliary stereo pair; `container.multi` separates untouched main audio from the key detector; an empty `container.chain` passes the main pair; `container.no_midi` protects the fixed-rate key oscillator; `dynamics.envelope_follower` analyses only the key slice; `control.pma_unscaled` multiplies raw maximum-cut dB by the follower amount; and `filters.svf_eq` applies the resulting peak cut after both slices have been processed.

Key rules:
  - Before ThirtyTwoSampleDucker: Thirty-two samples is a maximum and a practical general-purpose follower cadence.
  - Before InternalSidechain: The auxiliary pair is generated internally and discarded on exit.
  - Before MainAudio: The empty branch intentionally passes main channels unchanged.
  - Before DynamicMidEQ: Process the key slice first by placing the EQ after ChannelSlices.
  - Before CutDepthPMA: Multiply normalised follower amount by raw negative MaxCut dB.
  - Before EQ smoothing: Keep it zero so it does not conceal follower timing or chunk cadence.

Public controls:
  - MaxCut -> CutDepthPMA.Value raw unscaled connection
  - Macro range: [-18, 0] dB
  - Default: -9 dB

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id SidechainDynamicMidCut --agent
hise-cli builder set --module SidechainDynamicMidCut --network sidechain_dynamic_mid_cut --agent

# Thirty-two samples is the maximum child chunk size and is a practical envelope-follower cadence.
hise-cli dsp add --module SidechainDynamicMidCut --type container.fix32_block --id ThirtyTwoSampleDucker --agent
# This creates and later discards an internal auxiliary pair; it is not an external DAW sidechain input.
hise-cli dsp add --module SidechainDynamicMidCut --type container.sidechain --id InternalSidechain --parent ThirtyTwoSampleDucker --agent
hise-cli dsp add --module SidechainDynamicMidCut --type container.multi --id ChannelSlices --parent InternalSidechain --agent
# Intentionally empty: channels 0-1 pass unchanged into the dynamic EQ.
hise-cli dsp add --module SidechainDynamicMidCut --type container.chain --id MainAudio --parent ChannelSlices --agent
hise-cli dsp add --module SidechainDynamicMidCut --type container.no_midi --id KeyDetector --parent ChannelSlices --agent
hise-cli dsp add --module SidechainDynamicMidCut --type core.oscillator --id KeyOscillator --parent KeyDetector --agent
hise-cli dsp add --module SidechainDynamicMidCut --type dynamics.envelope_follower --id KeyFollower --parent KeyDetector --agent
# Value carries raw negative dB; Multiply receives the normalised follower amount.
hise-cli dsp add --module SidechainDynamicMidCut --type control.pma_unscaled --id CutDepthPMA --parent KeyDetector --agent
# Keep the EQ after ChannelSlices so key analysis completes before each EQ chunk.
hise-cli dsp add --module SidechainDynamicMidCut --type filters.svf_eq --id DynamicMidEQ --parent InternalSidechain --agent

hise-cli dsp set --module SidechainDynamicMidCut --node KeyOscillator --param Frequency --range "0.5,8" --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyOscillator --param Frequency --value 2 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyFollower --param Attack --value 10 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyFollower --param Release --value 150 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyFollower --param ProcessSignal --value 0 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node CutDepthPMA --param Multiply --range "0,1" --agent

hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Mode --value 4 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Frequency --value 1800 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Q --value 2 --agent
# EQ smoothing must remain zero so the follower and fixed-block cadence remain authoritative.
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Smoothing --value 0 --agent
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Gain --range "0,-18" --stepSize 0.1 --agent

hise-cli dsp create_parameter --module SidechainDynamicMidCut --container sidechain_dynamic_mid_cut --id MaxCut --range "-18,0" --default -9 --stepSize 0.1 --agent
hise-cli dsp connect --module SidechainDynamicMidCut --source sidechain_dynamic_mid_cut --source-param MaxCut --target CutDepthPMA --param Value --agent
hise-cli dsp connect --module SidechainDynamicMidCut --source KeyFollower --target CutDepthPMA --param Multiply --agent
hise-cli dsp connect --module SidechainDynamicMidCut --source CutDepthPMA --target DynamicMidEQ --param Gain --agent

hise-cli dsp set --module SidechainDynamicMidCut --node ThirtyTwoSampleDucker --param NodeColour --value 0xFF2F80ED --agent
hise-cli dsp set --module SidechainDynamicMidCut --node ThirtyTwoSampleDucker --param Comment --value '"**Sidechain dynamic mid cut** - Thirty-two-sample chunks provide a practical envelope-follower cadence for frequency ducking."' --agent
hise-cli dsp set --module SidechainDynamicMidCut --node InternalSidechain --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node InternalSidechain --param Comment --value '"Creates an internal auxiliary pair for teaching; this is not an external DAW sidechain input."' --agent
hise-cli dsp set --module SidechainDynamicMidCut --node ChannelSlices --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node MainAudio --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node MainAudio --param Comment --value '"Intentionally empty: channels 0-1 pass unchanged before the dynamic EQ."' --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyDetector --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyOscillator --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node KeyFollower --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node CutDepthPMA --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node CutDepthPMA --param Comment --value '"Multiplies raw negative MaxCut dB by the normalised key envelope."' --agent
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param NodeColour --value 0xFF6F8FAF --agent
hise-cli dsp set --module SidechainDynamicMidCut --node DynamicMidEQ --param Comment --value '"Placed after channel slicing so key analysis updates Gain before each EQ chunk; Smoothing remains zero."' --agent
hise-cli dsp set --module SidechainDynamicMidCut --node MainAudio --param Folded --value true --agent
```

