---
title: Choke Group Processor
moduleId: ChokeGroupProcessor
type: MidiProcessor
subtype: MidiProcessor
tags: [note_processing]
builderPath: b.MidiProcessors.ChokeGroupProcessor
screenshot: /images/v2/reference/audio-modules/chokegroupprocessor.png
cpuProfile:
  baseline: negligible
  polyphonic: false
  scalingFactors: []
seeAlso: []
commonMistakes:
  - wrong: "Expecting ChokeGroup 0 to pass all MIDI through unchanged"
    right: "Set both LoKey to 0 and HiKey to 127 alongside ChokeGroup 0 for full passthrough"
    explanation: "Key range filtering is always active regardless of the ChokeGroup setting. Notes outside the LoKey-HiKey range are blocked even when the choke group is disabled."
  - wrong: "Placing two ChokeGroupProcessors in separate synth chains and expecting them to be independent"
    right: "Assign different ChokeGroup numbers to processors that should not choke each other"
    explanation: "Choke group matching is global across the entire module tree. Any two processors with the same group number will choke each other, even if they are in unrelated synth chains."
  - wrong: "Setting KillVoice to On for instruments that need a natural release tail when choked"
    right: "Set KillVoice to Off to allow envelope release stages to play out"
    explanation: "KillVoice On instantly silences voices with no release phase. KillVoice Off sends a note-off instead, allowing envelopes to complete their release stage naturally."
customEquivalent:
  approach: hisescript
  moduleType: ScriptProcessor
  complexity: medium
  description: "A HISEScript MIDI processor can replicate the choke behaviour using Message.ignoreEvent() for key filtering, Synth.addNoteOff() or Engine.allNotesOff() for voice stopping, and a shared script variable or global lookup for group matching. The sustain pedal tracking and cross-processor communication require additional scripting effort."
llmRef: |
  ChokeGroupProcessor (MidiProcessor)

  Assigns the parent sound generator to a numbered choke group (1-16). When a note-on arrives, the processor broadcasts a choke message to all other ChokeGroupProcessors sharing the same group number. Those processors then kill or release their parent synth's active voices. This models the behaviour of instruments where one sound cuts off another - e.g. open and closed hi-hats on a drum kit.

  Signal flow:
    MIDI event in -> key range filter (LoKey/HiKey) -> event tracking -> choke broadcast to same-group processors -> MIDI event out (passthrough)

  CPU: negligible (no per-sample processing, only event-level logic).

  Parameters:
    ChokeGroup (0-16, default 0) - group number; 0 disables choke behaviour
    LoKey (0-127, default 0) - lowest note that triggers choke and starts voices
    HiKey (0-127, default 127) - highest note that triggers choke and starts voices
    KillVoice (Off/On, default On) - On: instant kill; Off: sends note-off for natural release

  Key behaviours:
    - Group 0 disables choke send/receive but key range filtering still applies
    - Choke matching is global across the entire module tree, not scoped to containers
    - Sustain pedal is tracked: sustained voices are also choked when a message arrives
    - Upstream transposition is respected when checking the key range

  When to use:
    Drum instruments where playing one articulation should silence another (hi-hat open/closed, snare buzz/rimshot). Place one ChokeGroupProcessor on each sound generator and assign the same group number.

  Common mistakes:
    - ChokeGroup 0 still filters by key range; set 0-127 for true passthrough
    - Groups are global, not container-scoped; use distinct numbers for independent groups
    - KillVoice On gives no release tail; use Off for natural fade-out

  See also: (none)
---

::category-tags
---
tags:
  - { name: note_processing, desc: "MIDI processors that transform, filter, or react to incoming note events." }
---
::

![ChokeGroupProcessor screenshot](/images/v2/reference/audio-modules/chokegroupprocessor.png)

The Choke Group Processor assigns its parent sound generator to a numbered choke group. When a note-on arrives within the key range, the processor broadcasts a choke message to all other Choke Group Processors sharing the same group number anywhere in the module tree. Those processors then stop their parent synth's active voices - either instantly or with a natural release, depending on the KillVoice setting. This models instruments where one sound cuts off another, such as open and closed hi-hats on a drum kit.

The processor operates in two roles simultaneously: as a sender (broadcasting choke messages on incoming note-ons) and as a receiver (stopping its own synth's voices when another processor in the same group broadcasts). Setting ChokeGroup to 0 disables both roles, though key range filtering remains active.

## Signal Path

::signal-path
---
glossary:
  parameters:
    ChokeGroup:
      desc: "Group number for choke matching (0 disables choke behaviour)"
      range: "0 - 16"
      default: "0"
    LoKey:
      desc: "Lowest note number that passes through and triggers choke"
      range: "0 - 127"
      default: "0"
    HiKey:
      desc: "Highest note number that passes through and triggers choke"
      range: "0 - 127"
      default: "127"
    KillVoice:
      desc: "On: instant voice kill; Off: note-off for natural release"
      range: "Off / On"
      default: "On"
  functions:
    trackEvent:
      desc: "Adds note-ons to the active events list; moves note-offs to the sustained events list"
    broadcastChoke:
      desc: "Notifies all other Choke Group Processors in the same group to stop their voices"
    stopVoices:
      desc: "Kills or releases all tracked active and sustained voices on the parent synth"
---

```
// Choke Group Processor - mutual voice silencing across sound generators
// MIDI event in -> MIDI event out (passthrough, with choke side-effects)

onMidiEvent(message) {
    if message is all-notes-off:
        clear active and sustained events
        return

    if message is sustain pedal (CC#64):
        update sustain state
        if pedal released: clear sustained events
        return

    if message is note-on:
        note = note number (including upstream transposition)
        if note < LoKey or note > HiKey:
            block message    // no voice starts, no choke
            return

    // Event tracking (only when ChokeGroup != 0)
    if ChokeGroup != 0:
        if note-on:  trackEvent(message -> active)
        if note-off: trackEvent(message -> sustained)

        if note-on:
            broadcastChoke(ChokeGroup)
            // Other processors in same group receive:
            //   if KillVoice: stopVoices(kill instantly)
            //   else:         stopVoices(send note-off)

    pass message through
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Choke Group
    params:
      - { name: ChokeGroup, desc: "Group number for choke matching. Processors with the same non-zero group number choke each other's voices. Set to 0 to disable choke behaviour (key range filtering still applies).", range: "0 - 16", default: "0" }
      - { name: KillVoice, desc: "Controls how choked voices are stopped. On: voices are killed instantly with no release phase. Off: a note-off is sent, allowing envelope release stages to play out naturally.", range: "Off / On", default: "On" }
  - label: Key Range
    params:
      - { name: LoKey, desc: "Lowest MIDI note number that passes through the processor. Note-ons below this value are blocked and do not trigger choke broadcasts. Respects upstream transposition.", range: "0 - 127", default: "0" }
      - { name: HiKey, desc: "Highest MIDI note number that passes through the processor. Note-ons above this value are blocked and do not trigger choke broadcasts. Respects upstream transposition.", range: "0 - 127", default: "127" }
---
::

## Notes

Choke group matching is global across the entire module tree. There is no way to scope groups to a specific container or synth chain. Two Choke Group Processors in completely separate synth chains with the same group number will choke each other. Use distinct group numbers for groups that should be independent.

The key range check respects upstream transposition. If a Transposer processor shifts incoming notes before they reach the Choke Group Processor, the transposed note number is used for the range check.

Sustain pedal behaviour is tracked: voices held by the sustain pedal (CC#64) are still choked when a choke message arrives. This is correct for drum instruments where a choke should silence all ringing voices regardless of pedal state.

The key range filter and the choke system are independent. Two processors in the same group can have different key ranges to create partial choke behaviour - for example, processor A filtering to note 36 (kick) and processor B filtering to note 42 (closed hi-hat) in the same group. Playing note 42 chokes any active note 36 voices on processor A's synth, and vice versa.
