Triggers a native C++ assertion that breaks into an attached C++ debugger (Visual Studio, Xcode). Only useful for HISE developers debugging HISE itself. For HISEScript debugging, use `Console.stop()` instead.

> [!Warning:$WARNING_TO_BE_REPLACED$] This breaks into the C++ debugger, not the HISEScript debugger. It has no effect if no native debugger is attached.
