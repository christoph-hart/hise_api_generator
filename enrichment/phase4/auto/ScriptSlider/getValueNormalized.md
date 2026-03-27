Converts the current value to normalised 0..1 space using the current range and midpoint mapping. Midpoint skew is only applied when `middlePosition` resolves to a numeric value inside the active range. This is useful when syncing with gesture surfaces, modulators, or generic UI code that works in normalised units.

> [!Warning:$WARNING_TO_BE_REPLACED$] Invalid range settings return `0.0`, so validate your range and midpoint before relying on the result.

> [!Warning:$WARNING_TO_BE_REPLACED$] Legacy `-1` midpoint values no longer act as a universal disable token. Use `"disabled"` to force linear no-skew conversion.
