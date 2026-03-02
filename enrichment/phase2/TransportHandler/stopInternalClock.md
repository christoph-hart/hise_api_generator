## stopInternalClock

**Examples:**

```javascript
// Title: Stop clock before destructive operations (preset load, channel reset)
// Context: Stopping playback before loading a preset or resetting channel data
// prevents timing artifacts and ensures a clean state transition. Multiple
// subsystems may need to stop the clock independently.
const var th = Engine.createTransportHandler();
th.setSyncMode(th.PreferInternal);

// Stop from UI play button (no audio context, use timestamp 0)
inline function onPlayButton(component, value)
{
    if (value)
        th.startInternalClock(0);
    else
        th.stopInternalClock(0);
}

// Stop from MIDI callback (use Message.getTimestamp() for sample accuracy)
// In onNoteOn:
// th.stopInternalClock(Message.getTimestamp());
```

**Pitfalls:**
- Multiple script files can call `stopInternalClock` on different TransportHandler instances -- the clock is global, so any instance can stop it. In a complex plugin, the clock may be stopped from transport UI, preset browser, mixer controls, and preset preview systems independently. Coordinate stop/restart sequences carefully when multiple subsystems interact.
