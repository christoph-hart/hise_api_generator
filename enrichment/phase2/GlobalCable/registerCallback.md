## registerCallback

**Examples:**


**Pitfalls:**
- When using `AsyncNotification`, the callback fires on the UI thread at the display refresh rate. If the cable value changes faster than the refresh rate (e.g., from an audio-rate DSP source), intermediate values are silently dropped. This is by design -- you only get the most recent value.
