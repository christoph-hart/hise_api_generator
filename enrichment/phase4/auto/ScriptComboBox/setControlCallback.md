Assigns a custom inline function as the control callback for this component, replacing the default `onControl` handler. The function receives two parameters: the component reference and the current value. Pass `undefined` to revert to the default `onControl` callback.

> **Warning:** The callback function must be declared with `inline function` and must have exactly two parameters. Regular function references are rejected with a script error.
