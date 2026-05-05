## flushMessageList

**Examples:**


**Pitfalls:**
- Every note-on must have a matching note-off in the list. Unpaired note-ons will sustain indefinitely during playback.
- Always call `setUseTimestampInTicks(true)` before flushing when the timestamps are in musical ticks, or the engine will interpret them as sample counts.
