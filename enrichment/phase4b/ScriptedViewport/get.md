ScriptedViewport::get(String propertyName) -> var

Thread safety: WARNING -- String involvement, atomic ref-count operations
Returns the current value of the named property. Reports a script error if the property does not exist. ScriptedViewport adds: scrollBarThickness, autoHide, useList, viewPositionX, viewPositionY, items, fontName, fontSize, fontStyle, alignment.
Required setup:
  const var vp = Content.getComponent("ViewportId");
  var v = vp.get("items");
Pair with: set (writes properties), getAllProperties (lists available property names)
Source:
  ScriptingApiContent.cpp  ScriptComponent::get() -> getScriptObjectProperty()
