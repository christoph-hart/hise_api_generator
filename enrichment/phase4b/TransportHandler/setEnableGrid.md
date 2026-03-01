TransportHandler::setEnableGrid(Integer shouldBeEnabled, Integer tempoFactor) -> undefined

Thread safety: UNSAFE -- calls reportScriptError on invalid input
Enables/disables the global high-precision grid timer at a musical subdivision.
tempoFactor is a TempoSyncer::Tempo index: 0=1/1, 5=1/4, 8=1/8, 11=1/16, 14=1/32, 17=1/64.
Dispatch/mechanics:
  if isPositiveAndBelow(tempoFactor, numTempos) -> getMasterClock().setClockGrid(shouldBeEnabled, t)
  else -> reportScriptError("Illegal tempo value. Use 1-18") -- note: error msg is wrong, 0 is valid
Pair with:
  setOnGridChange -- must enable grid before grid callbacks fire
  setLocalGridMultiplier -- per-instance rate division
Anti-patterns:
  - Error message says "Use 1-18" but index 0 (Whole note) is valid
Source:
  ScriptingApi.cpp:8626  setEnableGrid() -> MasterClock::setClockGrid()
