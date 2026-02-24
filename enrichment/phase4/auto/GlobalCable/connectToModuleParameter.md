Connects the cable to a specific parameter of a HISE module. The `targetObject` JSON defines the target range (`MinValue`, `MaxValue`, optional `SkewFactor`, `StepSize`) and an optional `SmoothingTime` in milliseconds for ramped transitions. The parameter can be specified by index or by name.

To disconnect, pass -1 as the parameter with a processor ID to remove all connections for that processor, or pass an empty processor ID with -1 to remove all module parameter connections from this cable entirely.
