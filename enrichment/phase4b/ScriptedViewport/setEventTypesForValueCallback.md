ScriptedViewport::setEventTypesForValueCallback(Array eventTypeList) -> undefined

Thread safety: UNSAFE
Specifies which table event types trigger the parent component's setValue() callback (enables undo support and value propagation). Defaults: SingleClick, DoubleClick, ReturnKey, SpaceKey. Requires table mode.
Required setup:
  const var vp = Content.getComponent("ViewportId");
  vp.setTableMode({});
  vp.setEventTypesForValueCallback(["Selection", "DoubleClick"]);
Dispatch/mechanics: Iterates event type strings, maps to EventType enum, sets flags on table model's value callback mask.
Pair with: setTableMode (must be called first), setTableCallback (registers the interaction handler), setValue (triggered by the configured events)
Anti-patterns: Must call setTableMode() first -- reports a script error otherwise. Only "Selection", "SingleClick", "DoubleClick", "ReturnKey" are legal. Passing "SliderCallback", "ButtonCallback", "SetValue", "Undo", or "DeleteRow" reports a script error.
Source:
  ScriptTableListModel.cpp  setEventTypesForValueCallback() -> validates event types -> sets valueCallbackFlags
