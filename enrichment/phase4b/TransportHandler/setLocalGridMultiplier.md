TransportHandler::setLocalGridMultiplier(Integer factor) -> undefined

Thread safety: SAFE
Sets per-instance grid rate divisor. Only every Nth grid tick passes through.
factor must be 1 or power of two (2,4,8,16,32,64). Clamped to [1,64].
Dispatch/mechanics:
  Stores localGridMultiplier and localBitShift = log2(factor)
  onGridChange() uses bit masking: (gridIndex & (multiplier-1)) to filter, then >> localBitShift for local index
Pair with:
  setEnableGrid -- sets the base grid rate
  getGridLengthInSamples -- accounts for this multiplier
Anti-patterns:
  - Do NOT pass non-power-of-two values -- reportScriptError
Source:
  ScriptingApi.cpp:8639  setLocalGridMultiplier() -> isPowerOfTwo check + jlimit(1,64) + log2
