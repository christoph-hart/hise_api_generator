## setUseTimestampInTicks

**Examples:**


**Pitfalls:**
- This setting affects both reading (`getEventList()`) and writing (`flushMessageList()`). If you read events in tick mode, you must also flush in tick mode, or the timestamps will be misinterpreted.
