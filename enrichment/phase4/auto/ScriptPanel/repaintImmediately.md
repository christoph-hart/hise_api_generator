Despite the name, this method behaves identically to `repaint()` - it schedules an asynchronous repaint rather than painting synchronously.

> **Warning:** The synchronous paint path was removed. Do not rely on the paint having completed after this call returns.
