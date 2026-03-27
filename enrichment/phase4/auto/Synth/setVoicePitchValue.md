Applies a pitch ratio to a specific voice identified by its zero-based voice index. The value is a linear pitch multiplier where 1.0 = original pitch, 0.5 = one octave down, 2.0 = one octave up. This method is intended for use inside Script Voice Start Modulators where the `voiceIndex` variable is available.

> [!Warning:$WARNING_TO_BE_REPLACED$] Out-of-range voice indices are silently ignored - no error is produced. Negative values are clamped to 0, which quietly sets the pitch on voice 0 instead of reporting an error.
