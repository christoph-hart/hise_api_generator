---
description: Compile-time array sizes for voices, channels, and routing matrices — must match exactly between HISE, project DLLs, and exported plugins.
---

Preprocessors in this category fix the compile-time array sizes that HISE uses for voices, audio channels and routing matrices. They set the main plugin output channel count, the FX plugin channel count, the standalone output count, the project-wide channel ceiling, the maximum polyphonic voice count per sound generator and the maximum channel width for scriptnode frame containers. Raising any of them increases the memory footprint of every polyphonic voice or routing destination regardless of runtime usage, so only raise them for projects that genuinely need more than the default. These values must match exactly between the HISE build, any project DLL and the exported plugin, otherwise the voice-indexed and channel-indexed arrays disagree at runtime.
