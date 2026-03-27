Returns the current display output value of the modulator, intended for UI visualisation. Poll this in a timer callback (around 30ms) to drive modulation indicators, LED displays, or arc overlays on knobs. For pitch-mode modulators, the value is normalised to 0.0-1.0 for display purposes rather than returning the raw pitch factor.

> [!Warning:Value lags by one audio buffer] The returned value lags behind the actual audio-thread output by one buffer. Do not use it for audio-rate logic or pitch calculations.
