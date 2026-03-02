Enables or disables the high-precision grid timer at a specific musical subdivision. The tempo factor is an index from 0 (whole note) through 18 (1/64T triplet) - common values include 8 (1/8 note), 11 (1/16 note), and 5 (1/4 note). You must enable the grid before `setOnGridChange()` callbacks will fire. When syncing MidiPlayers to the master clock via `setSyncToMasterClock(true)`, they follow this grid automatically.

> **Warning:** The error message says "Use 1-18" but valid indices start at 0 (Whole note). Index 0 is valid.
