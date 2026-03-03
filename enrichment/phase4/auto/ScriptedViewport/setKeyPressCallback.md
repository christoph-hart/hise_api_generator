Registers a callback that fires when a consumed key is pressed while this component has focus. The callback receives an event object with properties including `isFocusChange`, `character`, `specialKey`, `keyCode`, `description`, and modifier flags (`shift`, `cmd`, `alt`).

> **Warning:** MUST call `setConsumedKeyPresses()` BEFORE calling this method. Reports a script error if `setConsumedKeyPresses` has not been called yet.
