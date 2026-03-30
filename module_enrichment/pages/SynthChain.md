---
title: Container
moduleId: SynthChain
type: SoundGenerator
subtype: SoundGenerator
tags: [container]
builderPath: b.SoundGenerators.SynthChain
screenshot: /images/v2/reference/audio-modules/synthchain.png
cpuProfile:
  baseline: negligible
  polyphonic: false
  scalingFactors: []
seeAlso:
  - { id: SynthGroup, type: alternative, reason: "Advanced container with shared modulation, FM synthesis, and unison. Use when children need common envelopes or pitch modulation." }
  - { id: GlobalModulatorContainer, type: companion, reason: "Hosts global modulators accessible from anywhere in the module tree. Must be placed as a child of a Container." }
commonMistakes:
   - title: "Only monophonic modulators on container"
     wrong: "Adding per-voice modulators (envelopes, velocity) to the Container's Gain Modulation chain"
     right: "Add per-voice modulators to each child synth's own Gain Modulation chain"
    explanation: "The Container's Gain Modulation only accepts monophonic (time-variant) modulators because it applies after all children are summed. For per-voice dynamics, modulate each child individually."
   - title: "Gain is linear, not decibels"
     wrong: "Setting Gain to control volume in decibels"
     right: "Use a SimpleGain effect in the FX chain for decibel-scaled volume"
    explanation: "The Gain parameter is normalised linear gain (0.0 to 1.0), not decibels. A SimpleGain effect provides a proper dB-scaled volume control."
   - title: "VoiceLimit per child, not global"
     wrong: "Expecting VoiceLimit to enforce a global voice limit across all children"
     right: "Set VoiceLimit on each child synth individually"
    explanation: "Each child manages its own voice pool independently. The Container's VoiceLimit affects the initial voice allocation when children are created but does not enforce a shared limit at runtime."
customEquivalent:
  approach: scriptnode
  moduleType: SoundGenerator
  complexity: medium
  description: "A scriptnode container with parallel routing of multiple sound generators and a summing output"
llmRef: |
  Container (SoundGenerator)

  The fundamental container module in HISE. Sums the audio output of child sound generators, applies monophonic gain modulation, and routes through a master effect chain. Every HISE project has a root Container ("Master Chain").

  Signal flow:
    MIDI in -> MIDI processors -> render all children (additive sum) -> monophonic gain modulation -> FX chain (master effects) -> Gain * Balance -> audio out

  CPU: negligible (all cost comes from children and effects), monophonic container

  Parameters:
    Gain (0-100%, default 100%) - output volume as linear gain (not dB), modulatable via monophonic Gain Modulation chain
    Balance (-1 to 1, default 0) - stereo balance applied at output
    VoiceLimit (1-256, default 256) - initial voice allocation for children
    KillFadeTime (0-20000 ms, default 20 ms) - fade-out when voices are killed

  Modulation chains:
    Gain Modulation - monophonic only (TimeVariantModulator). Scales the summed output of all children.

  When to use:
    Organising sound generators into layers. The root Container is always present. Nested Containers group children for shared FX processing or separate output routing.

  Common mistakes:
    Per-voice modulators on Container's gain chain - only monophonic modulators allowed.
    Expecting VoiceLimit to be a global limit - each child manages its own voice pool.
    Using Gain for dB control - it is linear 0-1, use SimpleGain effect for dB.

  Custom equivalent:
    scriptnode SoundGenerator with parallel routing.

  See also:
    alternative SynthGroup - advanced container with shared modulation, FM, and unison
    companion GlobalModulatorContainer - hosts global modulators, placed as child of Container
---

::category-tags
---
tags:
  - { name: container, desc: "Modules that host and organise child processors" }
---
::

![Container screenshot](/images/v2/reference/audio-modules/synthchain.png)

The Container is the fundamental organising module in HISE. It holds any number of child sound generators and sums their audio output into a single stereo bus. A monophonic gain modulation chain scales the combined output, and a master effect chain processes the result before it reaches the parent or the audio output.

Every HISE project has a root Container (the "Master Chain") that serves as the top-level module. The root Container handles MIDI channel filtering, host transport information, macro controls, and preset serialisation. Nested Containers behave as simple mixers without these global responsibilities. Any sound generator type can be added as a child, including other Containers for hierarchical organisation.

## Parameters

::parameter-table
---
groups:
  - label: Output
    params:
      - { name: Gain, desc: "Output volume as normalised linear gain (not decibels). Modulatable via the Gain Modulation chain. Use a SimpleGain effect in the FX chain for decibel-scaled control.", range: "0 - 100%", default: "100%" }
      - { name: Balance, desc: "Stereo balance applied when copying the processed signal to the output.", range: "-1 - 1", default: "0" }
  - label: Voice Management
    params:
      - { name: VoiceLimit, desc: "Initial voice allocation for child sound generators. Each child manages its own voice pool independently - this is not a shared global limit.", range: "1 - 256", default: "256" }
      - { name: KillFadeTime, desc: "Fade-out time when voices are killed by exceeding the voice limit or by a voice killer.", range: "0 - 20000 ms", default: "20 ms" }
---
::

## Modulation Chains

::modulation-table
---
chains:
  - { name: "Gain Modulation", desc: "Scales the summed output of all children. Applied as a monophonic per-sample multiply after all children have rendered. Only time-variant (monophonic) modulators are allowed - no envelopes or voice-start modulators.", scope: "monophonic", constrainer: "TimeVariantModulator" }
---
::

## Notes

The Pitch Modulation chain is intentionally disabled on the Container. Child sound generators have their own pitch modulation chains for per-voice pitch control.

The FX chain accepts master effects only (reverb, delay, convolution, etc.). Voice-level effects added to the chain are forced into monophonic processing mode. For per-voice effects, add them to the individual child synth FX chains.

The root Container provides additional functionality not available on nested Containers: MIDI channel filtering (enabling/disabling specific MIDI channels), macro control hosting (up to 8 macros mappable to any parameter in the tree), host transport forwarding, and multi-channel output routing.

Children render in tree order (top to bottom). Each child adds its output to the shared buffer, so the mixing is purely additive with no inter-child modulation. For shared modulation across children (common envelopes, shared pitch), use a Synthesiser Group instead.

**See also:** $MODULES.SynthGroup$ -- Advanced container with shared modulation, FM synthesis, and unison. Use when children need common envelopes or pitch modulation., $MODULES.GlobalModulatorContainer$ -- Hosts global modulators accessible from anywhere in the module tree. Must be placed as a child of a Container.
