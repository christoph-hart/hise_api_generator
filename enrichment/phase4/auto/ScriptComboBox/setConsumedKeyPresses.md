Defines which key presses this component intercepts. Pass `"all"` to catch all key presses exclusively, or `"all_nonexclusive"` to catch them while still allowing the parent to receive them. You can also pass a JSON object or array of objects specifying individual keys by `keyCode`, with optional `shift`, `cmd`, and `alt` modifiers.

> **Warning:** Must be called before `setKeyPressCallback()`. Calling the callback registration first reports a script error.
