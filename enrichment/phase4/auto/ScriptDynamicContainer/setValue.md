Sets the container's own value. This is thread-safe and can be called from any callback context. It sets the container-level value, not individual child values - use ContainerChild's `setValue()` for dynamic children.

> [!Warning:$WARNING_TO_BE_REPLACED$] If called during onInit, the value will not be restored after recompilation. Do not pass a String value.
