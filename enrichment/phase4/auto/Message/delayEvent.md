Adds a sample offset to the event's timestamp, pushing it later in time within the audio buffer. If the resulting timestamp exceeds the current buffer size, the event is automatically carried over to a future buffer. The delay is additive relative to the event's existing timestamp.

> [!Warning:$WARNING_TO_BE_REPLACED$] This delays when the event is *processed*, not where sample playback begins. To skip ahead in a sample without delaying the event, use `Message.setStartOffset()` instead.

> [!Warning:$WARNING_TO_BE_REPLACED$] When using this for humanisation, guard with `Message.isArtificial()` so that only sequencer-generated notes are delayed. Live MIDI input should pass through without added latency.
