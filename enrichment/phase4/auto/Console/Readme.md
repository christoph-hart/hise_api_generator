# Console

`Console` is a global debugging utility available in every HISEScript context. It provides methods for printing messages to the HISE console, asserting conditions during development, benchmarking code execution time, setting breakpoints, and recording data sampling sessions.

The assertion methods (`assertTrue`, `assertEqual`, `assertIsDefined`, `assertLegalNumber`, `assertIsObjectOrArray`, `assertNoString`, `assertWithMessage`) throw a script error when their condition fails, making them useful for catching invalid state early during development. For timing code, `Console.startBenchmark()` and `Console.stopBenchmark()` measure elapsed time with high-resolution precision. The `stop()` method acts as a conditional breakpoint that halts script execution, and `blink()` flashes the calling line in the code editor for quick visual tracing.

Most Console output -- including `print()`, `stopBenchmark()`, and `blink()` -- only produces visible results when running inside the HISE IDE. In exported plugins, these calls become no-ops, and the compiler strips all `Console.*` calls entirely in release builds so there is no performance cost to leaving them in your code. The data sampling methods (`startSampling`, `sample`) require the profiling toolkit to be enabled.
