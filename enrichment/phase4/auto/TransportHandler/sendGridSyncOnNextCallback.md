Forces the next grid callback to report itself as the first grid event in playback, allowing sequencers to reset their position counters. The typical use is after a preset load: stop the clock, load the preset, call `sendGridSyncOnNextCallback()`, then restart the clock.

> **Warning:** This is a global operation - it affects all TransportHandler instances, not just the one you call it on. In a multi-instance setup, calling this from any handler resets the grid sync flag for all handlers.
