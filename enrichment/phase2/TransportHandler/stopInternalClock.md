## stopInternalClock

**Examples:**

```javascript:stop-clock-before-destructive
// Title: Stop clock before destructive operations (preset load, channel reset)
// Context: Stopping playback before loading a preset or resetting channel data
// prevents timing artifacts and ensures a clean state transition.
// --- setup ---
const var th0 = Engine.createTransportHandler();
th0.setSyncMode(th0.InternalOnly);
th0.startInternalClock(0);
// --- end setup ---
const var th = Engine.createTransportHandler();

// Start the clock, then stop it before a destructive operation
th.startInternalClock(0);
th.stopInternalClock(0);
```
```json:testMetadata:stop-clock-before-destructive
{
  "testable": true,
  "verifyScript": {"type": "REPL", "expression": "th.isPlaying()", "value": false}
}
```


**Pitfalls:**
- Multiple script files can call `stopInternalClock` on different TransportHandler instances -- the clock is global, so any instance can stop it. In a complex plugin, the clock may be stopped from transport UI, preset browser, mixer controls, and preset preview systems independently. Coordinate stop/restart sequences carefully when multiple subsystems interact.
