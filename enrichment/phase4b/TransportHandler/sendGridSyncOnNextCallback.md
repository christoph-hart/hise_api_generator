TransportHandler::sendGridSyncOnNextCallback() -> undefined

Thread safety: SAFE
Forces next grid callback to have firstGridInPlayback=true. Global operation.
Dispatch/mechanics:
  getMasterClock().setNextGridIsFirst() -- direct delegation
Pair with:
  setOnGridChange -- the callback that receives the firstGridInPlayback flag
Source:
  ScriptingApi.cpp:8704  sendGridSyncOnNextCallback() -> MasterClock::setNextGridIsFirst()
