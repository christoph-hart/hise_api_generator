ScriptButton::set(String propertyName, NotUndefined value) -> undefined

Thread safety: UNSAFE
Sets a component property to the given value. Reports a script error if the
property does not exist. During onInit, changes are applied without UI notification;
outside onInit, sends change notifications to update the UI.

Anti-patterns:
  - Do NOT use an invalid property name -- throws a script error

Pair with:
  get -- read back a property value
  setPropertiesFromJSON -- batch property assignment

Source:
  ScriptingApiContent.cpp  ScriptComponent::set()
    -> property tree mutation with optional change notification
