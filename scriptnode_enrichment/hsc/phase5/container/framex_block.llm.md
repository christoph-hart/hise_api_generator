---
id: container.framex_block.dynamic-width-three-level-pm-cascade
node: container.framex_block
domain: scriptnode
category: dsp-network
title: "Dynamic-Width Three-Level PM Cascade"
summary: "Enables per-sample processing for child nodes with a dynamic channel count that adapts to the network context."
useCase: "Demonstrate that `container.framex_block` performs per-sample processing with a channel width inherited from its parent. With one child in a stereo `container.multi`, it processes both channels; adding another multi child would leave it one channel."
difficulty: advanced
networkName: three_level_phase_modulation
moduleType: ScriptSynth
moduleId: ThreeLevelPhaseModulation
tags:
  - container
  - framex
  - block
  - block-size
  - processing-context
aliases:
  - dynamic-width three-level pm cascade
  - framex block container
relatedNodes:
  - container.framex_block
  - container.multi
  - math.clear
  - core.oscillator
  - math.sig2mod
  - core.peak
  - envelope.simple_ar
  - envelope.voice_manager
  - core.mono2stereo
parameters:
  None: "None"
---

scriptnode example: container.framex_block

Dynamic-Width Three-Level PM Cascade.

Demonstrate that `container.framex_block` performs per-sample processing with a channel width inherited from its parent. With one child in a stereo `container.multi`, it processes both channels; adding another multi child would leave it one channel.

Graph:
```text
three_level_phase_modulation
  ChannelAllocator      container.multi
    DynamicFrames       container.framex_block
      OSC1              container.chain
        InputClear      math.clear
        Sine1           core.oscillator
      OSC2              container.chain
        Normalise1      math.sig2mod
        Peak1           core.peak
        Clear1          math.clear
        Sine2           core.oscillator
      OSC3              container.chain
        Normalise2      math.sig2mod
        Peak2           core.peak
        Clear2          math.clear
        Sine3           core.oscillator
      ENV               container.chain
        OutputEnvelope  envelope.simple_ar
        VoiceLifecycle  envelope.voice_manager
  StereoOutput          core.mono2stereo
```

Host:
  Module: ThreeLevelPhaseModulation
  Network: three_level_phase_modulation
  Type: `ScriptSynth`
  Builder setup: `add ScriptSynth as "ThreeLevelPhaseModulation"`, then set its network to `three_level_phase_modulation`.

Support nodes:
  Required: container.multi, math.clear, core.oscillator, math.sig2mod, core.peak, envelope.simple_ar, envelope.voice_manager, core.mono2stereo
  `container.multi` determines the channel slice assigned to the dynamic frame child; an initial `math.clear` removes host input; three MIDI-pitched sine oscillators create the PM cascade; each `math.sig2mod` converts a bipolar sine to normalized control before `core.peak` exports its current frame value; intermediate clear nodes isolate the final carrier; a simple AR and voice manager provide playable voice lifetime; and `core.mono2stereo` copies channel 0 to channel 1 after the multi container.

Key rules:
  - Adding a second multi child changes framex from two inherited channels to one.
  - math.sig2mod must precede each peak to avoid folding the negative sine half-cycle.
  - Clear each modulator only after exporting its normalized per-sample value.
  - core.mono2stereo requires an existing stereo context and copies channel 0 to channel 1.
  - Polyphonic interpreted framex processing should be compiled to C++.

Public controls:
  - None

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptSynth --id ThreeLevelPhaseModulation --agent
hise-cli builder set --module ThreeLevelPhaseModulation --network three_level_phase_modulation --agent

# One multi child receives the complete stereo slice. Adding a second child would reduce each slice to one channel.
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.multi --id ChannelAllocator --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.framex_block --id DynamicFrames --parent ChannelAllocator --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node DynamicFrames --param IsVertical --value false --agent

# Horizontal frame layout containing four vertical serial stage groups.
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.chain --id OSC1 --parent DynamicFrames --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC1 --param IsVertical --value true --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.chain --id OSC2 --parent DynamicFrames --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC2 --param IsVertical --value true --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.chain --id OSC3 --parent DynamicFrames --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC3 --param IsVertical --value true --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type container.chain --id ENV --parent DynamicFrames --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node ENV --param IsVertical --value true --agent

# Oscillator stage 1 clears host input and generates the first phase modulator.
hise-cli dsp add --module ThreeLevelPhaseModulation --type math.clear --id InputClear --parent OSC1 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.oscillator --id Sine1 --parent OSC1 --agent

# sig2mod maps -1..1 to 0..1 before peak, avoiding absolute-value folding at zero.
hise-cli dsp add --module ThreeLevelPhaseModulation --type math.sig2mod --id Normalise1 --parent OSC2 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.peak --id Peak1 --parent OSC2 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type math.clear --id Clear1 --parent OSC2 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.oscillator --id Sine2 --parent OSC2 --agent

hise-cli dsp add --module ThreeLevelPhaseModulation --type math.sig2mod --id Normalise2 --parent OSC3 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.peak --id Peak2 --parent OSC3 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type math.clear --id Clear2 --parent OSC3 --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.oscillator --id Sine3 --parent OSC3 --agent

hise-cli dsp add --module ThreeLevelPhaseModulation --type envelope.simple_ar --id OutputEnvelope --parent ENV --agent
hise-cli dsp add --module ThreeLevelPhaseModulation --type envelope.voice_manager --id VoiceLifecycle --parent ENV --agent
# mono2stereo copies channel 0 to channel 1 in the existing stereo synth context.
hise-cli dsp add --module ThreeLevelPhaseModulation --type core.mono2stereo --id StereoOutput --agent

# MIDI supplies each oscillator base frequency; static ratios define the PM structure.
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine1 --param 'Freq Ratio' --range "0.5,2" --middlePosition 1 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine1 --param 'Freq Ratio' --value 2 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine2 --param 'Freq Ratio' --range "0.5,2" --middlePosition 1 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine2 --param 'Freq Ratio' --value 0.5 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine3 --param 'Freq Ratio' --range "0.5,2" --middlePosition 1 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine3 --param 'Freq Ratio' --value 1 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Sine3 --param Gain --value 0.15 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OutputEnvelope --param Attack --value 5 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OutputEnvelope --param Release --value 80 --agent

hise-cli dsp connect --module ThreeLevelPhaseModulation --source Peak1 --target Sine2 --param Phase --agent
hise-cli dsp connect --module ThreeLevelPhaseModulation --source Peak2 --target Sine3 --param Phase --agent
hise-cli dsp connect --module ThreeLevelPhaseModulation --source OutputEnvelope --source-output 1 --target VoiceLifecycle --param 'Kill Voice' --agent

# Comments explain channel adaptation, signal conversion, voice lifetime, and output behavior at the nodes they constrain.
hise-cli dsp set --module ThreeLevelPhaseModulation --node three_level_phase_modulation --param Comment --value '"**CPU warning** - Polyphonic interpreted framex processing is extremely expensive. Compile this network to C++ for practical use."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node ChannelAllocator --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node ChannelAllocator --param Comment --value '"With one child, DynamicFrames inherits both stereo channels. Add a second multi child and its frame width becomes one channel."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node DynamicFrames --param NodeColour --value 0xFF8E44AD --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node DynamicFrames --param Comment --value '"Horizontal layout presents four vertical serial stages; framex still processes every inherited channel one sample at a time."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC1 --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC1 --param Comment --value '"Clear host audio, then generate the 2.0-ratio first phase modulator."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC2 --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC2 --param Comment --value '"sig2mod preserves the bipolar sine shape as 0..1 phase control before peak exports it; clear then starts the 0.5-ratio oscillator."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC3 --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node OSC3 --param Comment --value '"The second normalized phase signal drives the 1.0-ratio carrier; intermediate audio is cleared first."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node ENV --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node ENV --param Comment --value '"The AR envelope shapes output and its Gate output releases the polyphonic voice."' --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node StereoOutput --param NodeColour --value 0xFF7F6A91 --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node StereoOutput --param Comment --value '"Copies channel 0 to channel 1, preserving dual-mono output whether framex receives one or two channels."' --agent

hise-cli dsp set --module ThreeLevelPhaseModulation --node InputClear --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Normalise1 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Peak1 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Clear1 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Normalise2 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Peak2 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node Clear2 --param Folded --value true --agent
hise-cli dsp set --module ThreeLevelPhaseModulation --node VoiceLifecycle --param Folded --value true --agent
```

