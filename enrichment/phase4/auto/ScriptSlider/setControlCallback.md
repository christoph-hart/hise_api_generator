Registers a custom slider callback `(component, value)` for control events. Use this when you want local callback handling instead of a single global `onControl` branch.

> **Warning:** The callback must be an inline function with exactly two parameters.

> **Warning:** Do not use this if the active scriptnode network is already forwarding controls to parameters; that path reports an error.
