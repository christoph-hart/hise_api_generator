Registers a buffer at a specific slot index for repeated streaming through the WebSocket connection. Once registered, call `updateBuffer()` with the same index to mark the buffer as dirty and trigger a send on the next communication cycle.

> [!Warning:$WARNING_TO_BE_REPLACED$] Silently does nothing if the second argument is not a Buffer object. No error is reported.
