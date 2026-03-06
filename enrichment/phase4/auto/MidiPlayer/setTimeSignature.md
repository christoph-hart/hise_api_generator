Sets the time signature and bar count of the current sequence from a JSON object with `Nominator`, `Denominator`, and `NumBars` properties. Optional `LoopStart` and `LoopEnd` properties set normalised loop boundaries (0.0 to 1.0). Returns true if the values are valid.

> **Warning:** The `Tempo` property returned by `getTimeSignature()` is read-only. Including it in the object passed to this method has no effect - tempo is always derived from the host or master clock.
