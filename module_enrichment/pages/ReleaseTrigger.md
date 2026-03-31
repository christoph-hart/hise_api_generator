---
title: ReleaseTrigger
moduleId: ReleaseTrigger
type: MidiProcessor
subtype: MidiProcessor
tags: [note_processing]
builderPath: b.MidiProcessors.ReleaseTrigger
screenshot: /images/v2/reference/audio-modules/releasetrigger.png
cpuProfile:
  baseline: negligible
  polyphonic: false
  scalingFactors: []
seeAlso: []
commonMistakes:
  - title: "Original events are always consumed"
    wrong: "Expecting the original noteOn to reach downstream processors"
    right: "Both the original noteOn and noteOff are consumed - only the release-triggered noteOn passes through"
    explanation: "The module silently consumes all incoming note events and only generates new noteOn events on key release. Pair it with a dedicated release sample group, not with a sustain layer."
  - title: "Time=0 with TimeAttenuate maximizes attenuation"
    wrong: "Setting Time to 0 s with TimeAttenuate enabled and expecting no attenuation"
    right: "Set TimeAttenuate to Off to disable attenuation entirely, or set Time to a value that covers the expected hold duration"
    explanation: "With Time at 0, even the briefest key press maps to the far right of the attenuation curve, making attenuation maximally aggressive. Most release notes will be heavily attenuated or silent."
customEquivalent:
  approach: hisescript
  moduleType: ScriptProcessor
  complexity: medium
  description: "A ScriptProcessor using onNoteOn/onNoteOff callbacks with a note-number-indexed array to store velocities and timestamps, Message.ignoreEvent() to consume originals, and Synth.addNoteOn() to inject release notes."
llmRef: |
  ReleaseTrigger (MidiProcessor)

  Converts noteOff events into noteOn events for release-triggered sample layers. Consumes all incoming noteOn and noteOff events, then generates a new artificial noteOn on each key release using the original noteOn's velocity.

  Signal flow:
    noteOn in -> store velocity + timestamp, consume original
    noteOff in -> consume original -> [optional: time-based velocity attenuation] -> inject artificial noteOn

  CPU: negligible (event-driven, no per-sample processing).

  Parameters:
    TimeAttenuate (Off/On, default Off) - enables time-based velocity attenuation
    Time (0-20 s, default 0 s) - normalisation window for hold-time attenuation
    TimeTable (table curve) - maps normalised hold time (0-1) to velocity multiplier (0-1)

  Interfaces: TableProcessor (one table: TimeTable attenuation curve)

  When to use:
    Triggering release samples (key-up layers) in a sampler instrument. Place it in a dedicated sound generator's MIDI chain so that only the release group receives the converted events.

  Key behaviours:
    - Both original noteOn and noteOff are consumed (ignored) - nothing passes through unchanged.
    - With TimeAttenuate on, longer key holds produce quieter release samples (shaped by the table curve).
    - With TimeAttenuate off, release velocity equals the original noteOn velocity.
    - MPE mode switches velocity source from the original noteOn to the noteOff velocity.
    - If attenuated velocity reaches 0, no release noteOn is generated (silent drop).

  Common mistakes:
    - Expecting originals to pass through: both noteOn and noteOff are consumed.
    - Time = 0 with TimeAttenuate on makes attenuation maximally aggressive - use Off to disable.

  See also: (none)
---

::category-tags
---
tags:
  - { name: note_processing, desc: "MIDI processors that transform, filter, or react to incoming note events" }
---
::

![ReleaseTrigger screenshot](/images/v2/reference/audio-modules/releasetrigger.png)

The ReleaseTrigger converts noteOff events into noteOn events for release-triggered sample layers. It consumes all incoming noteOn and noteOff events, storing each noteOn's velocity and timestamp indexed by note number. When a key is released, it generates a new artificial noteOn using the stored velocity and injects it into the MIDI chain. This makes downstream sound generators play their samples on key release rather than key press.

An optional time-based velocity attenuation feature scales the release velocity according to how long the key was held. A table curve defines the attenuation shape: short holds can produce full-velocity releases whilst long holds fade to silence (or any other curve shape). When attenuation is disabled, the original noteOn velocity passes through at full strength. In MPE mode, the velocity source switches from the original noteOn velocity to the noteOff velocity.

## Signal Path

::signal-path
---
glossary:
  parameters:
    TimeAttenuate:
      desc: "Enables time-based velocity attenuation"
      range: "Off / On"
      default: "Off"
    Time:
      desc: "Normalisation window for hold-time attenuation"
      range: "0 - 20 s"
      default: "0 s"
  functions:
    lookupTable:
      desc: "Reads the TimeTable attenuation curve at the normalised time position, returning a velocity multiplier (0.0-1.0)"
    injectNoteOn:
      desc: "Creates an artificial noteOn from the stored event with the scaled velocity and injects it into the MIDI chain"
---

```
// ReleaseTrigger - noteOff to noteOn conversion
// MIDI noteOn/noteOff in -> artificial noteOn out (on key release)

onNoteOn(message) {
    store message velocity and timestamp at noteNumber
    consume original noteOn
}

onNoteOff(message) {
    consume original noteOff
    retrieve stored noteOn for noteNumber

    if TimeAttenuate is on:
        elapsedTime = now - storedTimestamp
        normalisedTime = clamp(elapsedTime / Time, 0, 1)
        attenuation = lookupTable(normalisedTime)    // TimeTable curve
    else:
        attenuation = 1.0

    velocity = storedVelocity * attenuation

    if velocity > 0:
        injectNoteOn(noteNumber, velocity)
    // else: silent drop, no event generated
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Time Attenuation
    params:
      - { name: TimeAttenuate, desc: "Enables time-based velocity attenuation. When off, release velocity equals the original noteOn velocity. The Time and TimeTable controls are hidden in the UI when this is off.", range: "Off / On", default: "Off" }
      - { name: Time, desc: "Normalisation window for hold-time attenuation. The elapsed hold time is divided by this value and clamped to 0-1 before the table lookup. Longer values spread the attenuation curve over a wider time range.", range: "0 - 20 s", default: "0 s" }
      - { name: TimeTable, desc: "Attenuation curve that maps normalised hold time to a velocity multiplier. The horizontal axis represents normalised time (0 = key just pressed, 1 = held for the duration set by Time or longer). The vertical axis is the velocity scale factor (0 = silent, 1 = full velocity).", range: "Table curve (0.0 - 1.0)", default: "Linear (identity)" }
---
::

## Notes

Both the original noteOn and noteOff events are consumed by this module - nothing passes through unchanged. Only the artificially generated release noteOn events reach downstream processors. This means the ReleaseTrigger should be placed in a dedicated sound generator's MIDI chain, separate from any sustain layers.

With Time set to 0 s and TimeAttenuate enabled, even the briefest key press maps to the far-right position of the attenuation curve. This makes the attenuation maximally aggressive. To disable attenuation entirely, set TimeAttenuate to Off rather than relying on a Time value.

When the attenuated velocity rounds down to 0, no release noteOn is generated. This is expected behaviour - the table curve can be shaped to intentionally silence releases beyond a certain hold duration.

The module supports full polyphonic note tracking across all 128 MIDI note numbers. However, overlapping notes on the same note number will overwrite the stored data - only the most recent noteOn for a given note number is retained.
