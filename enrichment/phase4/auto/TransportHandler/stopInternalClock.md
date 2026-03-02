Stops the internal master clock. Stop the clock before loading presets or resetting sequencer state to prevent timing discontinuities - call `sendGridSyncOnNextCallback()` before restarting to ensure a clean resync.

> **Warning:** The clock is global - any TransportHandler instance can stop it. In a complex plugin, the clock may be stopped from transport UI, preset browser, mixer controls, and preset preview systems independently. Coordinate stop/restart sequences carefully.
