Registers a callback that fires on each grid tick. The callback receives three arguments: the grid index (integer, adjusted for the local multiplier), a timestamp (sample offset within the current audio block for sample-accurate scheduling), and a boolean indicating whether this is the first grid tick in the current playback session or after a discontinuity.

> **Warning:** The grid must be enabled via `setEnableGrid(true, tempoFactor)` before this callback can fire. Without it, the callback is registered but never triggered - no error is reported.
