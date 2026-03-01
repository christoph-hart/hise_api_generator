TransportHandler::stopInternalClock(Integer timestamp) -> undefined

Thread safety: SAFE
Stops the internal master clock at the given sample offset. Global operation.
Dispatch/mechanics:
  clock.changeState(timestamp, true, false) -- mirror of startInternalClock
  Same immediate callback processing pattern
Pair with:
  startInternalClock -- start the internal clock
  stopInternalClockOnExternalStop -- auto-stop on DAW stop
Source:
  ScriptingApi.cpp:8684  stopInternalClock() -> MasterClock::changeState(false)
