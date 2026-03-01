TransportHandler::setLinkBpmToSyncMode(Integer shouldPrefer) -> undefined

Thread safety: SAFE
Links BPM source selection to the active sync mode. Global setting.
Dispatch/mechanics:
  getMasterClock().setLinkBpmToSyncMode(shouldPrefer) -- direct delegation
Pair with:
  setSyncMode -- the sync mode determines which BPM source is used
Source:
  ScriptingApi.cpp:8709  setLinkBpmToSyncMode() -> MasterClock::setLinkBpmToSyncMode()
