---
title: MIDI Player
moduleId: MidiPlayer
type: MidiProcessor
subtype: MidiProcessor
tags: [sequencing, generator]
builderPath: b.MidiProcessors.MidiPlayer
screenshot: /images/v2/reference/audio-modules/midiplayer.png
cpuProfile:
  baseline: low
  polyphonic: false
  scalingFactors: []
seeAlso:
  - { id: MidiMetronome, type: companion, reason: "Generates metronome clicks synchronised to this player's position and time signature" }
commonMistakes:
  - wrong: "Pressing play without loading a MIDI file first"
    right: "Load a MIDI file via the scripting API or drag-and-drop overlay, then call play()"
    explanation: "With no sequence loaded, CurrentSequence is 0 (no selection) and playback produces no output."
  - wrong: "Setting LoopStart to create a play region in one-shot mode"
    right: "Enable looping if you need the playback region to start at LoopStart"
    explanation: "In one-shot mode, playback always starts from the beginning and stops at LoopEnd. LoopStart only takes effect when LoopEnabled is on."
  - wrong: "Expecting the MIDI file to play at its embedded tempo"
    right: "Set the host tempo to match the desired playback speed"
    explanation: "Playback is always synchronised to the host tempo. The MIDI file's embedded tempo is discarded on load. Use PlaybackSpeed to scale relative to the host."
customEquivalent:
  approach: hisescript
  moduleType: "ScriptProcessor"
  complexity: complex
  description: "Requires manual tick-to-sample conversion, host tempo tracking, loop wrap-around logic, and artificial note generation via Message.makeArtificial(). Recording adds further complexity."
llmRef: |
  MidiPlayer (MidiProcessor)

  Plays back MIDI sequences synchronised to host tempo. Loads standard MIDI files from the pool and injects note, CC, and pitch wheel events into the MIDI buffer with sample-accurate timing. Supports looping, one-shot playback, variable speed, multi-track selection, and overdub recording.

  Signal flow:
    [MIDI file sequence] -> fetch events for current tick range -> convert to sample-accurate events -> MIDI buffer out
    Incoming MIDI passes through; captured only during recording.

  CPU: low (event fetch is a sequential scan, max 16 events per block), monophonic, constant cost.

  Parameters:
    CurrentPosition (0-100%, default 0%) - normalised playback position, read-write (seeking supported), not saved with presets
    CurrentSequence (0-16, default 0) - 1-based sequence index; 0 = no sequence selected
    CurrentTrack (1-16, default 1) - selects which track of a multi-track MIDI file to play and edit
    LoopEnabled (Off/On, default On) - toggles looping vs one-shot playback
    LoopStart (0-100%, default 0%) - loop region start; only used when looping is enabled
    LoopEnd (0-100%, default 100%) - playback endpoint in both loop and one-shot modes
    PlaybackSpeed (0.01-16.0, default 1.0) - speed multiplier on top of host tempo sync

  Transport: controlled via play() / stop() / record() from the scripting API. Optionally syncs to the master clock.

  When to use:
    Playing back pre-composed MIDI sequences (melodies, arpeggios, drum patterns) in sync with the host. Provides loop regions, multi-track selection, and recording/overdub.

  Common mistakes:
    Must load a MIDI file before playback - CurrentSequence defaults to 0 (no selection).
    LoopStart has no effect in one-shot mode.
    MIDI files play at host tempo, not their embedded tempo.

  See also: MidiMetronome (companion - generates clicks from this player's position).
---

::category-tags
---
tags:
  - { name: sequencing, desc: "MIDI processors that generate or play back note sequences" }
  - { name: generator, desc: "Modulators that create modulation signals internally, such as envelopes and LFOs. Contains modulators and MIDI processors." }
---
::

![MIDI Player screenshot](/images/v2/reference/audio-modules/midiplayer.png)

The MIDI Player loads standard MIDI files and plays them back as sample-accurate MIDI events synchronised to the host tempo. It injects note-on, note-off, CC, and pitch wheel events into the MIDI buffer from the selected sequence and track. Incoming MIDI passes through unmodified unless recording is active, in which case live input is captured into the sequence.

Playback supports looping with adjustable loop boundaries, one-shot mode (play once and stop), variable speed relative to the host tempo, and multi-track selection for MIDI files containing multiple tracks. Transport is controlled via the scripting API (`play()`, `stop()`, `record()`) or optionally synchronised to the master clock. MIDI files are loaded from the HISE pool system and can also be dragged onto the overlay in the editor.

## Signal Path

::signal-path
---
glossary:
  parameters:
    CurrentPosition:
      desc: "Normalised playback position (read-write; setting it seeks)"
      range: "0 - 100%"
      default: "0%"
    CurrentSequence:
      desc: "1-based sequence index; 0 means no sequence selected"
      range: "0 - 16"
      default: "0"
    CurrentTrack:
      desc: "Selects which track of a multi-track MIDI file to play and edit"
      range: "1 - 16"
      default: "1"
    LoopEnabled:
      desc: "Toggles between looping and one-shot playback"
      range: "Off / On"
      default: "On"
    LoopStart:
      desc: "Loop region start position (only used when looping)"
      range: "0 - 100%"
      default: "0%"
    LoopEnd:
      desc: "Playback endpoint in both loop and one-shot modes"
      range: "0 - 100%"
      default: "100%"
    PlaybackSpeed:
      desc: "Speed multiplier applied on top of host tempo sync"
      range: "0.01 - 16.0"
      default: "1.0"
  functions:
    calculateTickRange:
      desc: "Converts the current audio block size to a tick range using host BPM and playback speed"
    fetchEvents:
      desc: "Retrieves all MIDI events from the sequence that fall within the tick range (max 16 per block)"
    wrapTickRange:
      desc: "Splits the tick range into before-wrap and after-wrap sub-ranges when it crosses the loop boundary"
    injectEvent:
      desc: "Converts a sequence event to a sample-accurate MIDI message and adds it to the output buffer"
---

```
// MidiPlayer - tempo-synced MIDI sequence playback
// MIDI file in -> MIDI events out (incoming MIDI passes through)

if not playing or CurrentSequence == 0:
    pass through incoming MIDI
    return

// Calculate tick range for this audio block
tickRange = calculateTickRange(hostBPM, PlaybackSpeed, blockSize)

// Fetch and inject events from the selected sequence and track
events = fetchEvents(CurrentSequence, CurrentTrack, tickRange)

if tickRange crosses LoopEnd:
    wrapTickRange(LoopStart, LoopEnd)
    // fetch events from the wrapped portion too

for each event in events:
    injectEvent(event)    // noteOn, noteOff, CC, pitch wheel

// Advance position
advance CurrentPosition

if CurrentPosition > LoopEnd:
    if LoopEnabled:
        CurrentPosition = LoopStart    // wrap around
    else:
        stop playback                  // one-shot: stop

// Recording (when in record state)
// Incoming live MIDI is captured with tick timestamps
// and merged into the current sequence
```

::

## Parameters

::parameter-table
---
groups:
  - label: Sequence Selection
    params:
      - { name: CurrentSequence, desc: "Selects which loaded MIDI sequence to play. Value is 1-based: 1 = first sequence, 2 = second, etc. A value of 0 means no sequence is selected and playback produces no output.", range: "0 - 16", default: "0" }
      - { name: CurrentTrack, desc: "Selects which track of a multi-track MIDI file to play and edit. Affects both the events generated during playback and the track displayed in editor overlays.", range: "1 - 16", default: "1" }
  - label: Transport
    params:
      - { name: CurrentPosition, desc: "Normalised playback position. Reading it returns the current position; setting it seeks to that point within the loop region. This parameter is not saved with presets.", range: "0 - 100%", default: "0%" }
      - { name: PlaybackSpeed, desc: "Speed multiplier applied on top of host tempo synchronisation. At 1.0, a 4-bar sequence plays over exactly 4 bars at the host tempo. At 2.0, it plays in half the time. Also multiplied by the global playback speed.", range: "0.01 - 16.0", default: "1.0" }
  - label: Loop Region
    params:
      - { name: LoopEnabled, desc: "When on, playback wraps from LoopEnd back to LoopStart. When off, playback runs once from the start to LoopEnd and then stops.", range: "Off / On", default: "On" }
      - { name: LoopStart, desc: "Start of the loop region. When looping, playback wraps to this position after reaching LoopEnd. Has no effect in one-shot mode.", range: "0 - 100%", default: "0%" }
      - { name: LoopEnd, desc: "End of the playback region. Acts as the endpoint in both looping and one-shot modes.", range: "0 - 100%", default: "100%" }
---
::

## Notes

Playback is always synchronised to the host tempo. The embedded tempo in MIDI files is discarded on load; all timing is recalculated relative to the host BPM. The internal tick resolution is 960 ticks per quarter note.

CurrentPosition is not saved with presets - it is purely runtime state. When playback starts, the position resets to the beginning of the sequence (or the loop region).

LoopStart and LoopEnd define the playback region. In one-shot mode (LoopEnabled off), LoopStart is ignored - playback runs from the beginning to LoopEnd and stops. In loop mode, the event fetcher handles wrap-around transparently, splitting the tick range at the loop boundary so events near the loop point are not dropped. Note-off events at the wrap boundary are skipped to prevent orphaned releases.

The player generates a maximum of 16 events per audio block. Very dense sequences may have events silently dropped if more than 16 fall within a single block.

When bypassed, note-on events are suppressed but CC and pitch wheel events still pass through.

The MidiOverlayPanel FloatingTile hosts several editor overlays for the MIDI Player: a note viewer, CC viewer, loop-based editor, and drag-and-drop file loader. Overlays connect to any MidiPlayer in the module tree and support real-time editing with undo/redo.

## See Also

::see-also
---
links:
  - { label: "MidiMetronome", to: "/v2/reference/audio-modules/effects/master/midimetronome", desc: "Generates metronome clicks synchronised to this player's position and time signature" }
---
::
