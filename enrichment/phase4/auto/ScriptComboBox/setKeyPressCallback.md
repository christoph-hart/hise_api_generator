Registers a callback that fires when a consumed key is pressed while this component has focus. The callback receives an event object with properties including `keyCode`, `character`, `shift`, `cmd`, `alt`, and boolean flags like `specialKey`, `isLetter`, `isDigit`. The callback also fires on focus changes with `isFocusChange` set to `true` and a `hasFocus` property.

> **Warning:** You must call `setConsumedKeyPresses()` before this method. Calling it without prior key registration reports a script error.
