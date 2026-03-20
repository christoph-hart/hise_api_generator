ScriptAudioWaveform::get(String propertyName) -> var

Thread safety: SAFE
Returns the current value of the named property. Reports a script error if the
property does not exist.

Pair with:
  set -- to modify the property value
  getAllProperties -- to discover valid property names

Source:
  ScriptingApiContent.cpp  ScriptComponent::get()
    -> propertyTree lookup with default fallback
