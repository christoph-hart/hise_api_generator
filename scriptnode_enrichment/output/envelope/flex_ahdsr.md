---
title: Flex AHDSR Envelope
description: "An advanced AHDSR envelope with per-segment curve shaping, three playback modes, and a draggable graph UI."
factoryPath: envelope.flex_ahdsr
factory: envelope
polyphonic: true
tags: [envelope, ahdsr, modulation, flex]
cpuProfile:
  baseline: low
  polyphonic: true
  scalingFactors: []
seeAlso:
  - { id: "envelope.ahdsr", type: alternative, reason: "Simpler AHDSR with fewer parameters when per-segment curves are not needed" }
  - { id: "envelope.voice_manager", type: companion, reason: "Connect the Gate output here to manage voice lifecycle" }
commonMistakes:
  - title: "Trigger mode skips the sustain phase"
    wrong: "Setting Mode to Trigger and expecting the envelope to hold at the Sustain level while the note is down."
    right: "Trigger mode plays through all stages without pausing at sustain. Use Note mode for standard sustain-hold behaviour."
    explanation: "In Trigger mode the envelope runs from attack through to release in one continuous pass, regardless of note-off timing. This is useful for percussive sounds but not for sustained notes."
  - title: "AttackLevel cannot be lower than Sustain"
    wrong: "Setting AttackLevel below the Sustain value and expecting a dip after the attack peak."
    right: "AttackLevel is clamped to be at least equal to Sustain. Lower the Sustain level if you need a lower attack peak."
    explanation: "The envelope enforces AttackLevel >= Sustain to maintain a coherent shape where the decay always moves downward."
llmRef: |
  envelope.flex_ahdsr

  Advanced AHDSR envelope with independent curve shaping per segment, three playback modes (Trigger, Note, Loop), and an interactive draggable graph. Multiplies audio by envelope value and sends CV + Gate modulation outputs.

  Signal flow:
    MIDI note-on/off -> state machine -> envelope value
    audio in * envelope value -> audio out
    envelope value -> CV output (0..1)
    voice active -> Gate output (0 or 1)

  CPU: low, polyphonic

  Parameters:
    Timing: Attack (0-30000 ms, default 5), Hold (0-30000 ms, default 0), Decay (0-30000 ms, default 100), Release (0-30000 ms, default 300)
    Levels: AttackLevel (0-1, default 1.0), Sustain (0-1, default 0.5)
    Curves: AttackCurve (0-1, default 0.5), DecayCurve (0-1, default 0.5), ReleaseCurve (0-1, default 0.5)
    Mode: Mode (Trigger / Note / Loop, default Note)

  When to use:
    When you need per-segment curve control, looping envelopes, or trigger-style one-shot envelopes. Use envelope.ahdsr for simpler cases.

  Common mistakes:
    - Trigger mode skips sustain hold
    - AttackLevel is clamped to >= Sustain

  See also:
    [alternative] envelope.ahdsr -- simpler AHDSR with fewer parameters
    [companion] envelope.voice_manager -- voice lifecycle from Gate output
---

The flex AHDSR is an advanced envelope with independent curve shaping for the attack, decay, and release segments. It adds three playback modes (Trigger, Note, Loop) and provides an interactive graph where you can drag points to adjust timing, levels, and curves directly. Like the standard AHDSR, it multiplies the input audio by the envelope value and sends CV and Gate modulation outputs.

The key differences from the standard [envelope.ahdsr]($SN.envelope.ahdsr$) are per-segment curve parameters, extended time ranges (up to 30 seconds), the Mode selector for one-shot and looping behaviour, and the absence of Retrigger and Gate parameters. Note-on always retriggers from the current value.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Attack:
      desc: "Rise time from zero to AttackLevel"
      range: "0 - 30000 ms"
      default: "5.0"
    Hold:
      desc: "Duration at AttackLevel before decay"
      range: "0 - 30000 ms"
      default: "0.0"
    Decay:
      desc: "Fall time from AttackLevel toward Sustain"
      range: "0 - 30000 ms"
      default: "100.0"
    Sustain:
      desc: "Hold level during note-on (Note mode) and decay target"
      range: "0.0 - 1.0"
      default: "0.5"
    Release:
      desc: "Fall time from current level to zero"
      range: "0 - 30000 ms"
      default: "300.0"
    Mode:
      desc: "Playback mode: Trigger (no sustain hold), Note (standard), Loop (repeats)"
      range: "Trigger / Note / Loop"
      default: "Note"
    AttackLevel:
      desc: "Peak level at end of attack, clamped to >= Sustain"
      range: "0.0 - 1.0"
      default: "1.0"
    AttackCurve:
      desc: "Shape of the attack segment"
      range: "0.0 - 1.0"
      default: "0.5"
    DecayCurve:
      desc: "Shape of the decay segment"
      range: "0.0 - 1.0"
      default: "0.5"
    ReleaseCurve:
      desc: "Shape of the release segment"
      range: "0.0 - 1.0"
      default: "0.5"
  functions:
    stateMachine:
      desc: "Counter-based state machine with shaped interpolation per segment"
    multiply:
      desc: "Applies the envelope value to each audio sample"
---

```
// envelope.flex_ahdsr - advanced AHDSR with per-segment curves
// audio + MIDI in -> audio out, CV out, Gate out

onNoteOn() {
    stateMachine.start()                // begin from ATTACK
}

process(input) {
    progress = counter / segmentTime    // normalised position in segment
    shaped = applyCurve(progress)       // curve shaping per segment
    value = lerp(startLevel, targetLevel, shaped)
    output = input * multiply(value)
    cvOut = value
}

onNoteOff() {
    if (Mode == Note)
        stateMachine.release()          // SUSTAIN -> RELEASE
    // Trigger mode: already past sustain
    // Loop mode: continues until gate off, then releases
}

// Modes:
//   Trigger: plays A-H-D-R without sustain hold
//   Note:    standard AHDSR with sustain hold
//   Loop:    repeats the full envelope while gate is active
```

::

## Parameters

::parameter-table
---
groups:
  - label: Timing
    params:
      - { name: Attack, desc: "Rise time from the previous level to AttackLevel.", range: "0 - 30000 ms", default: "5.0" }
      - { name: Hold, desc: "Duration at AttackLevel before the decay phase begins.", range: "0 - 30000 ms", default: "0.0" }
      - { name: Decay, desc: "Fall time from AttackLevel toward the Sustain level.", range: "0 - 30000 ms", default: "100.0" }
      - { name: Release, desc: "Fall time from the current level to zero after note-off (or after sustain in Trigger mode).", range: "0 - 30000 ms", default: "300.0" }
  - label: Levels
    params:
      - { name: AttackLevel, desc: "Peak level at the end of attack and during hold. Clamped to be at least equal to Sustain.", range: "0.0 - 1.0", default: "1.0" }
      - { name: Sustain, desc: "Level held during the sustain phase (Note mode) and the target for the decay phase.", range: "0.0 - 1.0", default: "0.5" }
  - label: Curves
    params:
      - { name: AttackCurve, desc: "Shape of the attack segment. 0.5 = linear. Below 0.5 = logarithmic (fast start). Above 0.5 = exponential (slow start).", range: "0.0 - 1.0", default: "0.5" }
      - { name: DecayCurve, desc: "Shape of the decay segment. Same curve mapping as AttackCurve.", range: "0.0 - 1.0", default: "0.5" }
      - { name: ReleaseCurve, desc: "Shape of the release segment. Same curve mapping as AttackCurve.", range: "0.0 - 1.0", default: "0.5" }
  - label: Mode
    params:
      - { name: Mode, desc: "Playback mode. Trigger: plays through without sustain hold. Note: standard AHDSR with sustain. Loop: repeats the full cycle while the gate is active.", range: "Trigger / Note / Loop", default: "Note" }
---
::

## Notes

- The graph UI allows direct manipulation: drag points to adjust timing, levels, and curve shapes interactively.
- There is no Retrigger or Gate parameter. Every note-on retriggers the envelope from its current value (not from zero), which avoids clicks. There is no manual gate input; the envelope is always driven by MIDI.
- In Loop mode, the envelope restarts from the attack phase each time it completes, creating a repeating cycle. It continues looping until note-off, at which point the release phase plays once.
- Stages with zero time are skipped automatically. Setting Hold to 0 makes the envelope behave like a standard ADSR.
- Parameter changes are smoothed to prevent clicks during playback.

**See also:** $SN.envelope.ahdsr$ -- simpler AHDSR with fewer parameters, $SN.envelope.voice_manager$ -- voice lifecycle management
