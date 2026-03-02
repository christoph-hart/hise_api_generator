Registers a callback for the high-precision grid timer. The callback receives a grid index, a sample-accurate timestamp offset within the current audio block, and a boolean indicating whether this is the first grid tick in the current playback session (useful for resetting sequencer position counters).

> **Warning:** The grid must be enabled via `setEnableGrid(true, tempoFactor)` before this callback can fire. Without it, the callback is registered but never triggered - no error is reported.

> **Warning:** Does not fire immediately upon registration.
