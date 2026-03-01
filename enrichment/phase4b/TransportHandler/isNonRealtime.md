TransportHandler::isNonRealtime() -> Integer

Thread safety: SAFE
Returns 1 if DAW is bouncing/exporting audio offline, 0 for realtime playback.
Dispatch/mechanics:
  getMainController_()->getSampleManager().isNonRealtime() -- lock-free read
Source:
  ScriptingApi.cpp:8714  isNonRealtime() -> SampleManager::isNonRealtime()
