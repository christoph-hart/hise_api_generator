TransportHandler::setOnSignatureChange(Number sync, Function f) -> undefined

Thread safety: UNSAFE -- allocates new Callback object on heap
Registers callback for time signature changes. Callback receives (nominator, denominator).
Fires immediately with current time signature on registration.
Required setup:
  const var th = Engine.createTransportHandler();
Dispatch/mechanics:
  Same dual-slot pattern as setOnTempoChange
  new Callback("onTimeSignatureChange", f, isSync, 2) -> call(nom, denom, {}, true)
Pair with:
  setOnBeatChange -- beat rate depends on time signature
Source:
  ScriptingApi.cpp:8472  setOnSignatureChange() -> new Callback("onTimeSignatureChange", f, isSync, 2)
