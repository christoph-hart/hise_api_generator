Registers a callback that fires on each musical beat. The callback receives the beat index and a boolean indicating whether this is the first beat of a new bar. The beat rate follows the time signature denominator - in 6/8 time, beats fire twice as often as in 3/4.

> **Warning:** Does not fire immediately upon registration (unlike `setOnTempoChange` and `setOnTransportChange`). The first callback arrives at the next beat boundary.
