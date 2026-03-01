TransportHandler::startInternalClock(Integer timestamp) -> undefined

Thread safety: SAFE
Starts the internal master clock at the given sample offset. Global operation.
Dispatch/mechanics:
  clock.changeState(timestamp, true, true)
  if inside audio rendering -> processAndCheckGrid() + createInternalPlayHead() + handleTransportCallbacks()
  Immediately triggers transport/grid callbacks for the current block when called from audio thread
Pair with:
  stopInternalClock -- stop the internal clock
  setSyncMode -- configure clock interaction mode first
Source:
  ScriptingApi.cpp:8669  startInternalClock() -> MasterClock::changeState() -> handleTransportCallbacks()
