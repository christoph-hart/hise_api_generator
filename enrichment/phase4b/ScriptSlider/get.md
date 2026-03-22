ScriptSlider::get(String propertyName) -> var

Thread safety: SAFE
Returns the current value of the named property, or default when unset.
Reports a script error for unknown property names.

Required setup:
  const var sl = Content.addKnob("MySlider", 0, 0);

Pair with:
  set -- updates the same property map
  setPropertiesFromJSON -- batch property updates

Source:
  ScriptingApiContent.cpp:2054  ValueTree-backed property read path
