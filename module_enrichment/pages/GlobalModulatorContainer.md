---
title: Global Modulator Container
moduleId: GlobalModulatorContainer
type: SoundGenerator
subtype: SoundGenerator
tags: [routing, container]
builderPath: b.SoundGenerators.GlobalModulatorContainer
screenshot: /images/v2/reference/audio-modules/globalmodulatorcontainer.png
cpuProfile:
  baseline: very low
  polyphonic: true
  scalingFactors: [number of hosted modulators, polyphonic envelope count]
seeAlso:
  - { id: GlobalEnvelopeModulator, type: target, reason: "Consumer that reads envelope values from this container" }
  - { id: GlobalVoiceStartModulator, type: target, reason: "Consumer that reads voice-start values from this container" }
  - { id: GlobalTimeVariantModulator, type: target, reason: "Consumer that continuously reads time-variant values from this container" }
  - { id: GlobalStaticTimeVariantModulator, type: target, reason: "Consumer that snapshots time-variant values at note-on from this container" }
  - { id: MatrixModulator, type: target, reason: "Matrix-based consumer that combines multiple modulators from this container" }
commonMistakes:
  - title: "Global Modulator Container is silent"
    wrong: "Expecting the Global Modulator Container to produce audio output"
    right: "The container produces silence - it exists solely to host modulators for sharing"
    explanation: "Despite being a Sound Generator, the container outputs no audio. Its only purpose is to host modulators whose values are read by Global Modulator consumers elsewhere in the module tree."
  - title: "Container blocks consumer modules"
    wrong: "Adding a Global Envelope or Global Voice Start consumer inside the container's own chain"
    right: "Place consumers in other Sound Generators' modulation chains"
    explanation: "The container's chain excludes all Global*Modulator consumer types to prevent circular references. Consumers must be placed in other Sound Generators."
customEquivalent:
  approach: scriptnode
  moduleType: SoundGenerator
  complexity: complex
  description: "No direct scriptnode equivalent. The global modulation system is a module-tree-level routing mechanism. In scriptnode, use global cables for similar cross-module value sharing."
llmRef: |
  Global Modulator Container (SoundGenerator)

  A silent Sound Generator that hosts modulators and makes their computed values available to consumer modules elsewhere in the module tree. Produces no audio output.

  Signal flow:
    MIDI input -> phantom voice allocation -> hosted modulators compute -> values stored in shared buffers -> consumers read from buffers

  Three data types shared:
    VoiceStart: 128-element per-note arrays (indexed by MIDI note number)
    TimeVariant: per-block shared buffers (monophonic)
    Envelope: per-voice event-indexed buffers (polyphonic, synced via event IDs)

  CPU: very low baseline. The container itself does no DSP. Hosted modulators compute as they would if placed locally. Sharing saves CPU when the same modulation drives multiple targets.

  Parameters:
    Gain (0-100%, default 25%) - vestigial, no audio effect
    Balance (-100L to 100R, default centre) - vestigial, no audio effect
    VoiceLimit (1-256, default 256) - limits phantom voices for polyphonic modulators
    KillFadeTime (0-20000 ms, default 20 ms) - fade time when phantom voices are killed

  Modulation chains:
    Global Modulators - hosts any modulator type except Global*Modulator consumers (prevents circular references)
    Pitch Modulation - disabled

  When to use:
    When the same modulation source (LFO, envelope, velocity, etc.) needs to drive parameters across multiple Sound Generators. Place the source modulator here once, then add lightweight consumer modules wherever needed.

  Common mistakes:
    Expecting audio output - it produces silence.
    Adding consumers inside the container's own chain - they are blocked by the constrainer.

  See also:
    target GlobalEnvelopeModulator, GlobalVoiceStartModulator, GlobalTimeVariantModulator, GlobalStaticTimeVariantModulator, MatrixModulator - consumer types that read from this container
---

::category-tags
---
tags:
  - { name: routing, desc: "Modules that forward, distribute, or proxy signals or events across the module tree" }
  - { name: container, desc: "Modules that hold and combine other sound generators" }
---
::

![Global Modulator Container screenshot](/images/v2/reference/audio-modules/globalmodulatorcontainer.png)

The Global Modulator Container is a silent Sound Generator that hosts modulators for sharing across the module tree. Add any standard modulator (LFO, envelope, velocity, random, etc.) to its Global Modulators chain, then place lightweight consumer modules in other Sound Generators' modulation chains to read from the shared source.

This is the producer half of HISE's global modulation system. It allocates phantom voices internally so that polyphonic modulators (envelopes, voice-start modulators) have the per-voice context they need, but it produces no audio output. The real CPU savings come from computing a modulation source once here instead of duplicating it across multiple targets.

## Signal Path

::signal-path
---
glossary:
  parameters:
    VoiceLimit:
      desc: "Maximum number of phantom voices for polyphonic modulator context"
      range: "1 - 256"
      default: "256"
  functions:
    renderModulators:
      desc: "Computes all hosted modulators and stores results in shared buffers"
  modulations:
    GlobalModulators:
      desc: "Hosts any modulator type (LFO, envelope, velocity, etc.) except Global*Modulator consumers"
      scope: "per-voice (envelopes) / monophonic (time-variant) / per-note (voice-start)"
---

```
// Global Modulator Container - silent sound generator
// MIDI in -> no audio out (modulation sharing only)

onNoteOn() {
    // Allocate phantom voice (up to VoiceLimit)
    // Provides per-voice state for polyphonic modulators
}

perBlock() {
    // Render all modulators in GlobalModulators chain
    renderModulators()

    // Results stored in shared buffers:
    //   Voice-start values -> 128-element per-note arrays
    //   Time-variant values -> per-block buffer
    //   Envelope values -> per-voice event-indexed buffers

    // Audio output = silence
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Inherited (Vestigial)
    params:
      - { name: Gain, desc: "Inherited from the Sound Generator base. Has no effect - the container produces no audio.", range: "0 - 100%", default: "25%" }
      - { name: Balance, desc: "Inherited from the Sound Generator base. Has no effect - the container produces no audio.", range: "-100L - 100R", default: "Centre" }
  - label: Voice Management
    params:
      - { name: VoiceLimit, desc: "Maximum number of phantom voices. These voices provide per-voice context for polyphonic modulators (envelopes, voice-start modulators). Reduce this to save memory if fewer simultaneous notes are needed.", range: "1 - 256", default: "256" }
      - { name: KillFadeTime, desc: "Fade-out time when phantom voices are killed by exceeding the voice limit. Only affects the internal voice lifecycle, not audio output.", range: "0 - 20000 ms", default: "20 ms" }
---
::

## Modulation Chains

::modulation-table
---
chains:
  - { name: Global Modulators, desc: "Hosts modulators whose values are shared with consumer modules elsewhere in the module tree. Any standard modulator type can be added except Global*Modulator consumers (to prevent circular references).", scope: "mixed (per-voice for envelopes, monophonic for time-variant, per-note for voice-start)", constrainer: "!Global*Modulator" }
---
::

## Notes

The Gain and Balance parameters are inherited from the Sound Generator base but have no audible effect. The modulation chain operates in a special mode where values are copied to shared buffers rather than applied as gain multiplication.

The Pitch Modulation chain is disabled and cannot be used.

Polyphonic envelope synchronisation between the container and consumers uses event IDs rather than voice indices. This means consumers work correctly even when the consumer's parent Sound Generator has a different voice allocation than the container. A two-phase release mechanism prevents envelope tails from being cut off prematurely when voices are reused.

**See also:** $MODULES.GlobalEnvelopeModulator$ -- reads per-voice envelope values from this container, $MODULES.GlobalVoiceStartModulator$ -- reads per-note voice-start values from this container, $MODULES.GlobalTimeVariantModulator$ -- continuously reads monophonic time-variant values from this container, $MODULES.GlobalStaticTimeVariantModulator$ -- snapshots a time-variant value at note-on from this container, $MODULES.MatrixModulator$ -- combines multiple modulators from this container via a connection matrix