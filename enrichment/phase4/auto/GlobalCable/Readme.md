# GlobalCable

GlobalCable is a named, project-wide data bus that routes normalised values (0..1) and arbitrary structured data between script processors, DSP networks, UI components, macros, and module parameters. You obtain a cable reference from the global routing manager with `Engine.getGlobalRoutingManager().getCable(cableId)`. Each cable has two independent channels: a value channel for normalised doubles, and a data channel for JSON/strings/buffers.

Each cable reference maintains a local input range that maps user-facing values to/from the internal 0..1 transport. For example, a cable with `setRange(20.0, 20000.0)` converts `setValue(440.0)` to 0.021 before sending, and converts 0.021 back to 440.0 when reading with `getValue()`. Value callbacks run either synchronously (inline on the calling thread) or asynchronously (polled on the UI thread, with coalescing). Data callbacks are always asynchronous.

A cable reference can register callbacks, or it can wire the cable directly into the HISE module tree with `connectToMacroControl()`, `connectToModuleParameter()`, or `connectToGlobalModulator()`. This eliminates script middlemen for DSP parameter routing.

Cable IDs with a `/` prefix (e.g. `/some_osc_id`) automatically become OSC addresses when the global routing system runs as an OSC server.

![Cable Value Dispatch Flow](topology_cable-dispatch.svg)

## Common Mistakes

- **Wrong:** Using a non-realtime-safe function as a synchronous callback
  **Right:** Use `inline function` or pass `AsyncNotification`
  *Synchronous callbacks run on the calling thread which may be the audio thread. Non-realtime-safe functions are silently rejected - the callback never fires.*

- **Wrong:** Calling `sendData()` from the audio thread
  **Right:** Move data sending to a timer or async context
  *`sendData()` allocates a MemoryOutputStream on the heap, which is not audio-thread safe.*

- **Wrong:** Polling `getValue()` in `onTimer` at 30ms for visual feedback without smoothing
  **Right:** Apply exponential smoothing (`smoothed = smoothed * 0.6 + newValue * 0.4`) before rendering
  *Raw cable values from DSP networks can change abruptly between timer ticks. Smoothing produces visually stable animations without requiring faster polling.*

- **Wrong:** Creating many cables with separate `getGlobalRoutingManager()` calls
  **Right:** Call `Engine.getGlobalRoutingManager()` once, store in `const var rm`, then call `rm.getCable()` for each cable
  *The routing manager is a singleton; repeated `getGlobalRoutingManager()` calls work but are wasteful. Cache the reference at init time.*

- **Wrong:** Using `registerCallback` with `SyncNotification` for UI updates
  **Right:** Use `AsyncNotification` or timer-polled `getValue()` for anything that triggers repaints
  *Synchronous callbacks run on the calling thread (possibly the audio thread). UI operations like `repaint()` or `Console.print()` are not realtime-safe and will silently fail or cause audio glitches.*
