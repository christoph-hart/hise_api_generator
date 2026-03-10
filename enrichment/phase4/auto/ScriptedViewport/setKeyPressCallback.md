Registers a callback that fires when a consumed key is pressed while this component has focus. The callback receives an event object:

```json
{
  "isFocusChange": false,
  "character": "a",
  "specialKey": false,
  "isWhitespace": false,
  "isLetter": true,
  "isDigit": false,
  "keyCode": 65,
  "description": "a",
  "shift": false,
  "cmd": false,
  "alt": false
}
```

When the component gains or loses focus, the callback fires with a different shape:

```json
{
  "isFocusChange": true,
  "hasFocus": true
}
```

Check `isFocusChange` first to determine which set of properties is available.

> **Warning:** MUST call `setConsumedKeyPresses()` BEFORE calling this method. Reports a script error if `setConsumedKeyPresses` has not been called yet.
