ScriptedViewport::set(String propertyName, NotUndefined value) -> undefined

Thread safety: UNSAFE
Sets a component property to the given value. Reports a script error if the property does not exist. During onInit, changes apply without UI notification; outside onInit, sends change notifications. ScriptedViewport adds: scrollBarThickness, autoHide, useList, viewPositionX, viewPositionY, items, fontName, fontSize, fontStyle, alignment. Setting viewPositionX/Y broadcasts the new scroll position to the underlying viewport.
Required setup:
  const var vp = Content.getComponent("ViewportId");
  vp.set("items", "A\nB\nC");
Dispatch/mechanics: Validates property exists. Sets value on property tree. Outside onInit, sends change notification via sendChangeMessage(). viewPositionX/Y changes broadcast via positionBroadcaster.
Pair with: get (reads property values), getAllProperties (lists available properties)
Source:
  ScriptingApiContent.cpp  ScriptComponent::set() -> setScriptObjectProperty() -> sendChangeMessage()
