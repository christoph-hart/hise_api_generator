ScriptSlider::set(String propertyName, NotUndefined value) -> undefined

Thread safety: UNSAFE
Sets a single property value on the slider.
Unknown property names report a script error.

Required setup:
  const var sl = Content.addKnob("MySlider", 0, 0);

Pair with:
  get -- reads individual property values
  setPropertiesFromJSON -- applies multiple properties in one pass

Source:
  ScriptingApiContent.cpp:2054  setScriptObjectPropertyWithChangeMessage dispatch
