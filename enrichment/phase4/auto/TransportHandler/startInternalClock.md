Starts the internal master clock. When calling from a MIDI callback, always pass `Message.getTimestamp()` for sample-accurate alignment. When calling from a UI button, 0 is fine since there is no MIDI timing context.

> **Warning:** Using 0 from a MIDI callback introduces up to one buffer's worth of timing jitter (e.g., ~5.8ms at 512 samples / 44.1kHz). Always use `Message.getTimestamp()` in `onNoteOn`.
