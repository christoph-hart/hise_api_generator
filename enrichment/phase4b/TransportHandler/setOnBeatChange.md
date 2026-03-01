TransportHandler::setOnBeatChange(Number sync, Function f) -> undefined

Thread safety: UNSAFE -- allocates new Callback, registers MusicalUpdateListener
Registers callback for musical beat events. Callback receives (beatIndex, isNewBar).
Does NOT fire immediately on registration (unlike tempo/transport).
Required setup:
  const var th = Engine.createTransportHandler();
Dispatch/mechanics:
  if f.isUndefined() -> removeMusicalUpdateListener(this)
  else -> addMusicalUpdateListener(this) + new Callback("onBeatChange", f, isSync, 2)
  Beat rate follows time signature denominator (6/8 = twice as fast as 3/4)
Pair with:
  setOnSignatureChange -- time signature affects beat rate
  setOnGridChange -- for sub-beat precision
Source:
  ScriptingApi.cpp:8573  setOnBeatChange() -> addMusicalUpdateListener() + new Callback()
