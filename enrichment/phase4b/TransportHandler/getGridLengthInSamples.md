TransportHandler::getGridLengthInSamples() -> Double

Thread safety: SAFE
Returns grid tick duration in samples. Accounts for BPM, grid tempo, local multiplier, sample rate.
Dispatch/mechanics:
  getBpm() -> getCurrentClockGrid() -> getTempoFactor() * localGridMultiplier
  -> TempoSyncer::getTempoInSamples(bpm, sr, tf)
Pair with:
  setEnableGrid -- sets base grid rate
  setLocalGridMultiplier -- affects the returned value
Source:
  ScriptingApi.cpp:8719  getGridLengthInSamples() -> TempoSyncer::getTempoInSamples()
