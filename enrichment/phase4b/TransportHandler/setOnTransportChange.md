TransportHandler::setOnTransportChange(Number sync, Function f) -> undefined

Thread safety: UNSAFE -- allocates new Callback object on heap
Registers callback for play/stop transport state changes. Fires immediately with current play state.
Required setup:
  const var th = Engine.createTransportHandler();
Dispatch/mechanics:
  Same as setOnTempoChange: sync/async dual-slot pattern via Callback struct
  Note: sync branch has copy-paste bug -- clears tempoChangeCallbackAsync instead of transportChangeCallbackAsync (line 8452)
Pair with:
  isPlaying -- query current state without callback
  setOnTempoChange -- often registered together
Anti-patterns:
  - Do NOT use regular function with SyncNotification
Source:
  ScriptingApi.cpp:8446  setOnTransportChange() -> new Callback("onTransportChange", f, isSync, 1)
