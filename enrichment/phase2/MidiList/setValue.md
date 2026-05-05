## setValue

**Examples:**

```javascript:track-velocity-for-release-triggers
// Title: Track velocity per note for release sample triggering
// Context: Sampler plugins need to recall each note's velocity when the
// key is released to play release samples at the matching dynamic level.

const var velocities = Engine.createMidiList();

// In onNoteOn:
velocities.setValue(Message.getNoteNumber(), Message.getVelocity());

// In onNoteOff:
Synth.playNote(Message.getNoteNumber(), velocities.getValue(Message.getNoteNumber()));
```
```json:testMetadata:track-velocity-for-release-triggers
{
  "testable": false,
  "skipReason": "Requires MIDI note-on/note-off events to populate Message.getNoteNumber() and Message.getVelocity()"
}
```


