TransportHandler::setOnBypass(Function f) -> undefined

Thread safety: UNSAFE -- allocates new Callback, registers with bypass handler
Registers callback for plugin bypass state changes. Always async (no sync parameter).
Callback receives (isBypassed: bool). Fires immediately with current state.
Required setup:
  const var th = Engine.createTransportHandler();
Dispatch/mechanics:
  new Callback("onGridChange", f, false, 1) -- note: internal name "onGridChange" is cosmetic copy-paste leftover
  getMainController()->getPluginBypassHandler().listeners.addListener(*this, onBypassUpdate, true)
  onBypassUpdate calls bypassCallback->call(state, {}, {}, true) -- always force-sync delivery
Source:
  ScriptingApi.cpp:8619  setOnBypass() -> new Callback() + addListener(onBypassUpdate)
