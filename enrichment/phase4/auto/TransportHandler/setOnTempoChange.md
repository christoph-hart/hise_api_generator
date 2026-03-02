Registers a callback that fires whenever the host tempo changes. The callback receives the new BPM value. It fires immediately upon registration with the current tempo, so you can initialize tempo-dependent state without a separate setup step.

> **Warning:** The initial fire upon registration is always synchronous regardless of the dispatch mode.
