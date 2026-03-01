TransportHandler::stopInternalClockOnExternalStop(Integer shouldStop) -> undefined

Thread safety: SAFE
Configures auto-stop of internal clock when DAW transport stops. Global setting.
Dispatch/mechanics:
  getMasterClock().setStopInternalClockOnExternalStop(shouldStop) -- direct delegation
Pair with:
  setSyncMode -- typically used with SyncInternal mode
Source:
  ScriptingApi.cpp:8467  stopInternalClockOnExternalStop() -> MasterClock::setStopInternalClockOnExternalStop()
