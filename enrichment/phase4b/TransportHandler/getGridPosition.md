TransportHandler::getGridPosition(Integer timestamp) -> Integer

Thread safety: SAFE
Returns current PPQ position as integer for the given sample offset.
Dispatch/mechanics:
  getMasterClock().getPPQPos(timestamp) -- lock-free read, truncated to int
Source:
  ScriptingApi.cpp:8734  getGridPosition() -> MasterClock::getPPQPos(timestamp)
