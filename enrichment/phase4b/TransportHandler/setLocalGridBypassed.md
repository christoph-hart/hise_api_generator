TransportHandler::setLocalGridBypassed(Integer shouldBeBypassed) -> undefined

Thread safety: SAFE
Bypasses grid callbacks for this instance. On unbypass, next grid fires as firstGridInPlayback.
Dispatch/mechanics:
  Sets localBypassed flag. onGridChange() returns early when localBypassed is true.
  On unbypass: nextLocalIsFirst = true
Source:
  ScriptingApi.cpp:8658  setLocalGridBypassed() -> sets localBypassed + nextLocalIsFirst
