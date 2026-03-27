Returns a string describing the current download state. The possible values are:

| Value | Description |
|-------|-------------|
| `"Waiting"` | Queued but not yet started |
| `"Downloading"` | Actively transferring data |
| `"Paused"` | Stopped via `stop()`, can be resumed |
| `"Completed"` | Transfer finished (success or failure) |
| `"Aborted"` | Cancelled via `abort()` |

> [!Warning:$WARNING_TO_BE_REPLACED$] `"Completed"` does not imply success - a connection failure also results in `"Completed"` status. Always check `data.success` alongside the status text to determine the outcome.