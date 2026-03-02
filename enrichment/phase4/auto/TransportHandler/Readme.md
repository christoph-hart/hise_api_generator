<!-- Diagram triage:
  - sync-async-dispatch: RENDER (threading distinction is critical and hard to convey in prose alone)
  - clock-sync-modes: CUT (6 modes already clear in a table; the state transitions are straightforward)
-->
# TransportHandler

TransportHandler lets you react to DAW transport events and build your own transport system with an internal clock. Create one with `Engine.createTransportHandler()` and register callbacks for the events you need: tempo changes, play/stop, beat positions, time signature changes, a high-precision grid timer, and plugin bypass. Each callback (except bypass) can be dispatched synchronously on the audio thread via `SyncNotification` or asynchronously on the UI thread via `AsyncNotification`. Synchronous callbacks must use `inline function`.

The class provides three tiers of usage. At its simplest, register `setOnTransportChange()` and `setOnTempoChange()` callbacks to follow the DAW - no sync mode setup needed. For plugins with their own play/stop controls, configure `setSyncMode()` to `PreferInternal`, use `startInternalClock()` / `stopInternalClock()` from UI buttons, and enable `stopInternalClockOnExternalStop(true)`. For a full transport system with MIDI-triggered playback, add `startInternalClock(Message.getTimestamp())` for sample-accurate clock starts, a host-sync toggle that dynamically switches between `PreferInternal` and `PreferExternal`, and bridge the transport callback to a Broadcaster for multi-file state propagation.

For sample-accurate sequencing, enable the grid with `setEnableGrid()` and register a grid callback via `setOnGridChange()`. The grid callback receives a timestamp offset for precise event placement within an audio block. Each TransportHandler instance can run at a different grid subdivision using `setLocalGridMultiplier()`, and can independently bypass its grid via `setLocalGridBypassed()`. Most other settings (sync mode, grid enable, grid sync reset) are global and affect all TransportHandler instances. When testing sync modes in the HISE IDE, the "external clock" is the IDE's built-in transport bar; in an exported plugin, it is the actual DAW transport.

![Sync vs Async Callback Dispatch](timing_sync-async-dispatch.svg)

## Common Mistakes

- **Wrong:** `th.setOnGridChange(SyncNotification, onGrid);` without calling `th.setEnableGrid(true, tempoFactor)`
  **Right:** Call `th.setEnableGrid(true, 7)` before registering the grid callback
  *The grid must be enabled before grid callbacks fire. Without it, the callback is registered but never triggered.*

- **Wrong:** Using a regular `function` with `SyncNotification`
  **Right:** Use `inline function` for synchronous callbacks
  *Synchronous callbacks run on the audio thread. A regular function throws "Must use inline functions for synchronous callback" at registration.*

- **Wrong:** Calling `startInternalClock(0)` from a MIDI callback
  **Right:** Call `startInternalClock(Message.getTimestamp())` from MIDI callbacks
  *Using 0 starts at the block boundary, introducing up to one buffer of timing jitter. The timestamp gives sample-accurate positioning.*

- **Wrong:** Updating UI components directly in the transport callback
  **Right:** Pass a Broadcaster as the callback function
  *Direct component updates create tight coupling when multiple script files need transport state. A Broadcaster enables loose coupling across listener sites.*

- **Wrong:** Not stopping the internal clock before loading a preset
  **Right:** Call `stopInternalClock(0)` before `Engine.loadUserPreset()`
  *Loading a preset while the clock runs causes timing discontinuities. Stop first, then call `sendGridSyncOnNextCallback()` and restart after load.*
