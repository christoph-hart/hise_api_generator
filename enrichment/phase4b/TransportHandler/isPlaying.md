TransportHandler::isPlaying() -> Integer

Thread safety: SAFE
Returns 1 if transport is playing, 0 if stopped. Respects current sync mode.
Dispatch/mechanics:
  getMasterClock().isPlaying() -- lock-free read
Pair with:
  setOnTransportChange -- callback-based alternative
Source:
  ScriptingApi.cpp:8729  isPlaying() -> MasterClock::isPlaying()
