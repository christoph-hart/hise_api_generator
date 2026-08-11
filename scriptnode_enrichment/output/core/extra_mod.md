---
title: core.extra_mod
description: "Picks up a modulation signal from an extra modulation chain of the parent module."
factoryPath: core.extra_mod
factory: core
polyphonic: true
tags: [core, modulation, bridge]
screenshot: /images/v2/reference/scriptnodes/core/extra_mod.png
cpuProfile:
  baseline: negligible
  polyphonic: true
  scalingFactors: []
seeAlso:
  - { id: "core.global_mod", type: alternative, reason: "Receives from GlobalModulatorContainer instead of extra mod chains" }
  - { id: "core.pitch_mod", type: companion, reason: "Similar bridge node for the pitch modulation chain" }
  - { id: "core.matrix_mod", type: alternative, reason: "Dual-source modulation with matrix processing features" }
commonMistakes:
  - title: "Missing MIDI processing context"
    wrong: "Placing core.extra_mod directly in a monophonic ScriptFX chain without a MIDI-aware parent"
    right: "In monophonic effect networks, wrap core.extra_mod in container.midichain. If frame processing is also needed, put frame2_block inside midichain, not the other way around."
    explanation: "extra_mod processes HISE events so it needs a MIDI-processing context: either a polyphonic root network or a container.midichain ancestor, with no container.no_midi ancestor."
  - title: "Missing preprocessor for mod slots"
    wrong: "Adding core.extra_mod without defining the preprocessor for the module type"
    right: "Set the appropriate preprocessor (e.g. HISE_NUM_SCRIPTNODE_FX_MODS=1) in the project settings."
    explanation: "Extra modulation chains must be enabled per module type via preprocessor definitions. Without them, no modulation slots are available and the node has nothing to connect to."
  - title: "Connecting root parameter to same index"
    wrong: "Connecting a root parameter target and an extra_mod node to the same modulation index"
    right: "Use either a root parameter connection or an extra_mod node for a given index, not both."
    explanation: "These two modes are mutually exclusive. If both are active on the same index, a warning icon appears and the behaviour is undefined."
  - title: "No root parameter assigned to the slot"
    wrong: "Adding core.extra_mod without setting External Modulation on a root parameter"
    right: "Set one root parameter's External Modulation mode (eg. Combined) so that its modulation slot index matches core.extra_mod.Index."
    explanation: "extra_mod reads an existing extra modulation slot. The slot is created by a root parameter with ExternalModulation enabled; otherwise validation reports 'No parameter assigned to modulation slot'."
llmRef: |
  core.extra_mod

  Picks up a modulation signal from an extra modulation chain of the parent module and exposes it inside scriptnode. The signal passes through unmodified (raw mode) -- no intensity scaling or mode formula is applied. The Index parameter selects which extra modulation chain slot to read from.

  Signal flow:
    parent module's extra mod chain -> raw passthrough -> modulation output (normalised 0-1)
    (optional) -> audio channel 0 when ProcessSignal is enabled

  CPU: negligible, polyphonic

  Parameters:
    Index (0 - 16, default 0): Selects which extra modulation chain to read from.
    ProcessSignal (Disabled / Enabled, default Disabled): Writes raw modulation to audio channel 0.

  When to use:
    - Bringing external modulation (LFOs, envelopes) into a scriptnode network
    - Per-voice modulation from the parent module's extra mod chains
    - Sample-accurate modulation of parameters within the network

  Required parent context:
    - core.extra_mod processes HISE events. In a monophonic ScriptFX network it must have a container.midichain ancestor.
    - A polyphonic root network already provides the MIDI-processing context.
    - Do not place it below container.no_midi.
    - If it must also run in a frame context, use midichain -> frame2_block -> extra_mod. container.midichain cannot be placed inside frame2_block.

  Required root parameter slot:
    - Enable External Modulation on one root parameter to create the extra modulation slot that extra_mod reads.
    - The root parameter's slot order must match extra_mod.Index. Index 0 reads the first root parameter with External Modulation enabled.
    - Use either direct root-parameter modulation or extra_mod pickup for a slot, not both.

  Common mistakes:
    - Missing MIDI-processing context for extra_mod
    - No root parameter assigned to the extra_mod slot
    - Must define preprocessor for extra mod slot count per module type
    - Cannot use root parameter connection and extra_mod on the same index

  See also:
    [alternative] core.global_mod -- receives from GlobalModulatorContainer
    [companion] core.pitch_mod -- bridge for pitch modulation chain
    [alternative] core.matrix_mod -- dual-source modulation with matrix features
---

![Extra Mod screenshot](/images/custom/scriptnode/extra_mod.png)

The extra mod node bridges HISE's modulation system into scriptnode by picking up signals from the extra modulation chains of the parent module. These are the additional modulation slots that a scriptnode module can expose -- for example, a filter's frequency modulation or a custom per-parameter modulation input. The signal passes through unmodified, preserving the raw normalised value (0-1) from the modulation chain.

To use this node, the parent module type must have extra modulation slots enabled with the matching preprocessor definition:

| Parent module type | Interpreted network | Compiled C++ network | Default |
|---|---|---|---|
| Script FX | `HISE_NUM_SCRIPTNODE_FX_MODS` | `NUM_HARDCODED_FX_MODS` | 0 |
| Polyphonic Script FX | `HISE_NUM_POLYPHONIC_SCRIPTNODE_FX_MODS` | `NUM_HARDCODED_POLY_FX_MODS` | 0 |
| Scriptnode Synthesiser | `HISE_NUM_SCRIPTNODE_SYNTH_MODS` | `NUM_HARDCODED_SYNTH_MODS` | 2 |

Set each macro to the required number of slots in the project settings' **Extra Definitions** field. These definitions are hot-reloaded when you reload the module; recompiling HISE is not required. Once configured, the modulation slots appear on the parent module and any HISE modulators added to those slots are picked up by this node.

## Required Parent Context

`core.extra_mod` is an event-processing modulation bridge. In a monophonic `ScriptFX` network, place it below a [container.midichain]($SN.container.midichain$) so it can receive HISE events from the parent module's extra modulation chain. A polyphonic root network already counts as MIDI-capable, so a separate midichain is not required there.

Do not place `core.extra_mod` below [container.no_midi]($SN.container.no_midi$). That container explicitly blocks event forwarding and invalidates the MIDI-processing context.

If the modulation pickup must feed sample-by-sample processing, put the frame container inside the midichain:

```text
container.midichain
  container.frame2_block
    core.extra_mod
    target nodes
```

Do not reverse that order. `container.midichain` cannot prepare inside a frame context, so `container.frame2_block -> container.midichain` is invalid.

## Required Root Parameter Slot

`core.extra_mod` does not create an extra modulation slot by itself. The slot is created by a root parameter whose `ExternalModulation` property is enabled, for example with the `Combined` mode. `core.extra_mod.Index` reads that slot by order: index `0` reads the first externally modulatable root parameter, index `1` reads the second, and so on.

If no root parameter is assigned to the selected slot, validation reports `No parameter assigned to modulation slot #N`. Use either the direct root-parameter modulation path or the `extra_mod` pickup path for a slot, not both.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Index:
      desc: "Selects which extra modulation chain slot to read from"
      range: "0 - 16"
      default: "0"
    ProcessSignal:
      desc: "When enabled, writes the modulation signal to audio channel 0"
      range: "Disabled / Enabled"
      default: "Disabled"
  functions:
    rawPassthrough:
      desc: "Forwards the modulation signal without any transformation"
---

```
// core.extra_mod - extra modulation chain bridge
// mod chain signal -> modulation output

process() {
    signal = readModChain(Index)

    // Raw passthrough -- no scaling or mode formula
    modOutput = rawPassthrough(signal)

    if ProcessSignal == Enabled {
        audio[ch0] = signal
    }
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Configuration
    params:
      - { name: Index, desc: "Selects which extra modulation chain to read from within the parent module. Index 0 reads the first chain, index 1 the second, and so on.", range: "0 - 16", default: "0" }
      - { name: ProcessSignal, desc: "When enabled, writes the raw modulation signal to audio channel 0 for further processing in the signal path.", range: "Disabled / Enabled", default: "Disabled" }
---
::

### Root parameter interaction

The extra mod node supports an interaction with root parameters: if a root parameter is configured with the Combined modulation mode and associated with the same index as an extra_mod node, the root parameter controls the base value of the modulation chain rather than directly setting the target. This enables modulation display on UI knobs while the actual modulation happens at full resolution inside the network.

If no `extra_mod` node matches the modulation index, the modulation signal is applied directly to the root parameter at the interval set by the network's `ModulationBlockSize`. A value of `0` uses the current audio buffer size.

### Compilation

If you plan to compile the DSP network to a C++ node, the corresponding hardcoded module preprocessor variables must also be set (e.g. `NUM_HARDCODED_FX_MODS`).

**See also:** $SN.core.global_mod$ -- receives from GlobalModulatorContainer instead of extra mod chains, $SN.core.pitch_mod$ -- bridge for the pitch modulation chain, $SN.core.matrix_mod$ -- dual-source modulation with matrix processing features
