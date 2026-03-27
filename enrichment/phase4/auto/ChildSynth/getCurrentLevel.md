Returns the current peak display level for the left (`true`) or right (`false`) channel. These values update at the UI refresh rate, making them suitable for driving VU meters and activity indicators in a `ScriptPanel` timer callback.

> [!Warning:$WARNING_TO_BE_REPLACED$] These are display-rate values, not sample-accurate measurements. Apply decay smoothing (e.g. `level = Math.max(newPeak, level * 0.85)`) for stable meter display - raw values fluctuate rapidly between timer ticks.
