## setPlaybackCallback

**Examples:**


When using multiple MidiPlayer instances with a shared callback, `this` inside the callback refers to the MidiPlayer that triggered it, allowing you to identify which player changed state.
