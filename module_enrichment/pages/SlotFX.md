---
title: Effect Slot
moduleId: SlotFX
type: Effect
subtype: MasterEffect
tags: [utility, routing]
builderPath: b.Effects.SlotFX
screenshot: /images/v2/reference/audio-modules/slotfx.png
cpuProfile:
  baseline: negligible
  polyphonic: false
  scalingFactors: []
seeAlso:
  - { id: EmptyFX, type: companion, reason: "The default placeholder loaded when the slot is empty or cleared" }
commonMistakes:
  - title: "No crossfade on effect swap"
    wrong: "Expecting a crossfade when swapping effects in the slot during playback"
    right: "The swap is instantaneous with no crossfade - plan for a brief audio interruption"
    explanation: "Effect swapping happens at the next processing boundary. There is no built-in crossfade between the old and new effects."
  - title: "Can't nest slots or load polyphonic"
    wrong: "Trying to load a polyphonic effect or another Effect Slot into the slot"
    right: "Only master effects and monophonic effects are allowed, excluding Route Effect and nested Effect Slots"
    explanation: "The slot restricts child types to prevent incompatible or recursive configurations."
llmRef: |
  Effect Slot (MasterEffect)

  A container that hosts a single swappable child effect. The hosted effect can be changed at runtime, making it useful for dynamic signal chains where the user selects from a list of effects. When empty, audio passes through unchanged.

  Signal flow:
    audio in -> [if effect loaded] child effect processing -> audio out
    audio in -> [if empty] -> audio out (passthrough)

  CPU: negligible (wrapper overhead only), monophonic. Actual CPU depends on the hosted effect.

  Parameters: none (all parameters belong to the hosted child effect).

  Allowed child effects: all master effects and monophonic effects except Route Effect and Effect Slot (no nesting).

  When to use:
    Building dynamic effect chains where the user can swap between different effects at runtime. Commonly used with scripting to create switchable effect racks.

  Common mistakes:
    No crossfade on swap - the transition is instantaneous.
    Only master/monophonic effects allowed, no polyphonic effects or nested slots.

  See also:
    companion Empty - default placeholder when slot is empty
---

::category-tags
---
tags:
  - { name: utility, desc: "Modules for analysis, placeholders, or structural purposes without audio processing" }
  - { name: routing, desc: "Modules that forward, distribute, or proxy signals or events across the module tree" }
---
::

![Effect Slot screenshot](/images/v2/reference/audio-modules/slotfx.png)

The Effect Slot hosts a single child effect that can be swapped at runtime. It is the standard building block for dynamic signal chains where the user selects from a list of available effects. When no effect is loaded, audio passes through unchanged.

The slot accepts all master effects and monophonic effects, excluding Route Effect and other Effect Slots (no nesting). MIDI events, bypass state, and monophonic voice lifecycle are all forwarded to the hosted effect. The slot itself has no parameters - all controls belong to the child.

## Notes

When an effect is swapped, the transition is instantaneous at the next processing boundary. There is no crossfade between the old and new effects, which may produce a brief audio discontinuity if the swap occurs during playback.

An empty slot always contains an Empty effect internally rather than being truly null. Clearing the slot replaces the current effect with a fresh Empty instance.

Two Effect Slots can exchange their hosted effects atomically using the swap operation, which is useful for reordering effects in a dynamic chain.

Bypass is fully delegated to the hosted effect. Bypassing the Effect Slot forwards the bypass state to whatever effect is currently loaded.

**See also:** $MODULES.EmptyFX$ -- The default placeholder loaded when the slot is empty or cleared
