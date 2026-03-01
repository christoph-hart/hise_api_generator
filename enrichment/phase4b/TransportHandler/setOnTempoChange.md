TransportHandler::setOnTempoChange(Number sync, Function f) -> undefined

Thread safety: UNSAFE -- allocates new Callback object on heap
Registers callback for tempo (BPM) changes. Fires immediately with current tempo on registration.
Required setup:
  const var th = Engine.createTransportHandler();
Dispatch/mechanics:
  ApiHelpers::isSynchronous(sync) -> new Callback(this, "onTempoChange", f, isSync, 1)
    sync: callSync() on audio thread | async: sendPooledChangeMessage() -> UI thread
  clearIf() removes opposite-mode slot for same function reference
Pair with:
  setOnTransportChange -- often registered together for full transport awareness
Anti-patterns:
  - Do NOT use regular function with SyncNotification -- throws "Must use inline functions for synchronous callback"
Source:
  ScriptingApi.cpp:8426  setOnTempoChange() -> new Callback() -> call(bpm, {}, {}, true)
