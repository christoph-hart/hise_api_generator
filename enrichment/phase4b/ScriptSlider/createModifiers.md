ScriptSlider::createModifiers() -> ScriptObject

Thread safety: UNSAFE
Creates a Modifiers script object containing action keys and modifier flag constants for setModifiers.

Required setup:
  const var sl = Content.addKnob("MySlider", 0, 0);

Pair with:
  setModifiers -- consumes Modifiers constants for action and flag mapping

Source:
  ScriptingApiContent.cpp:2054  ScriptSlider::ModifierObject creation and constant registration
