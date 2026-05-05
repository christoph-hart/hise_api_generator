## setSyncToMasterClock

**Examples:**


**Pitfalls:**
- The master clock grid must be enabled via `TransportHandler.setEnableGrid(true, gridIndex)` before calling `setSyncToMasterClock(true)`. Otherwise a script error is thrown.
- Once synced, `play()` and `stop()` return `false` without doing anything. This is by design - use the TransportHandler to control transport.
- `record()` has special behavior when synced and stopped: it sets a flag to start recording when the clock next starts, rather than starting immediately.
