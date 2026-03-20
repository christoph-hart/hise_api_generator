ScriptAudioWaveform::set(String propertyName, NotUndefined value) -> undefined

Thread safety: UNSAFE
Sets a component property to the given value. Reports a script error if the
property does not exist. Outside onInit, sends change notifications to update
the UI.

Pair with:
  get -- to read the property value
  getAllProperties -- to discover valid property names

Source:
  ScriptingApiContent.cpp  ScriptComponent::set()
    -> setScriptObjectPropertyWithChangeMessage()
