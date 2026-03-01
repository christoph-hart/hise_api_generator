TransportHandler::setOnGridChange(Number sync, Function f) -> undefined

Thread safety: UNSAFE -- allocates new Callback, registers MusicalUpdateListener
Registers callback for high-precision grid events. Callback receives (gridIndex, timestamp, firstGridInPlayback).
Grid must be enabled via setEnableGrid() first. Does NOT fire immediately on registration.
Required setup:
  const var th = Engine.createTransportHandler();
  th.setEnableGrid(true, 11); // 1/16 note
Dispatch/mechanics:
  Same MusicalUpdateListener pattern as setOnBeatChange
  Grid index adjusted by localGridMultiplier (bit shift + mask filtering)
  timestamp = sample offset within audio block for sample-accurate scheduling
Pair with:
  setEnableGrid -- must enable grid first (silent no-op otherwise)
  setLocalGridMultiplier -- per-instance rate division
  getGridLengthInSamples -- compute grid duration
Anti-patterns:
  - Do NOT register grid callback without calling setEnableGrid first -- silently never fires
Source:
  ScriptingApi.cpp:8596  setOnGridChange() -> addMusicalUpdateListener() + new Callback("onGridChange", f, isSync, 3)
