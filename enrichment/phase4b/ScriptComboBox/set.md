ScriptComboBox::set(String propertyName, NotUndefined value) -> undefined

Thread safety: UNSAFE
Sets a component property to the given value. Reports a script error if the
property does not exist. During onInit, changes apply without UI notification;
outside onInit, sends change notifications to update the UI.
Dispatch/mechanics:
  setScriptObjectPropertyWithChangeMessage(id, value)
    -> if property is "items": updates Items property, recalculates max from item count
    -> delegates to ScriptComponent base for all other properties
Pair with:
  get -- read back property values
  getAllProperties -- list available property IDs
Anti-patterns:
  - Do NOT set "items" with comma-separated text -- items must be newline-separated.
    Commas create a single item containing the full text.
Source:
  ScriptingApiContent.cpp:2988  ScriptComboBox::setScriptObjectPropertyWithChangeMessage()
    -> updates max to getItemList().size() when Items property changes
