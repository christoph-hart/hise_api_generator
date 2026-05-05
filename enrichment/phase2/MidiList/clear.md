## clear

**Examples:**

```javascript:deduplication-during-pedal-release
// Title: Deduplication during sustain pedal release
// Context: When the sustain pedal lifts, all sustained notes need release
// samples - but each note should only trigger once. Clear the list first,
// then use it as a "seen set" while processing the held notes.

const var processed = Engine.createMidiList();
const var heldNotes = Engine.createUnorderedStack();
heldNotes.setIsEventStack(true, heldNotes.EventId);

const var holder = Engine.createMessageHolder();

// When pedal releases, process each held note exactly once
inline function onPedalRelease()
{
    processed.clear();

    while (!heldNotes.isEmpty())
    {
        heldNotes.storeEvent(0, holder);
        heldNotes.removeElement(0);

        // Skip if this note number was already processed
        if (processed.getValue(holder.getNoteNumber()) != -1)
            continue;

        processed.setValue(holder.getNoteNumber(), 1);
        Synth.addMessageFromHolder(holder);
    }
}
```
```json:testMetadata:deduplication-during-pedal-release
{
  "testable": false,
  "skipReason": "Requires MIDI note-on events and sustain pedal interaction to populate the UnorderedStack"
}
```


