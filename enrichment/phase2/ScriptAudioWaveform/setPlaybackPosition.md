## setPlaybackPosition

**Examples:**


**Pitfalls:**
- After changing the `processorId` property at runtime, always call `setPlaybackPosition(0)` to reset the cursor. The display does not auto-reset when the data source changes.
