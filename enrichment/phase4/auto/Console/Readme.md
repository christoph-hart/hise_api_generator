# Console

Console provides debugging and diagnostic tools for HISEScript development in the HISE IDE. The class offers three main capabilities: output methods for logging values and clearing the console, assertion methods for validating conditions and data types during development, and profiling tools for benchmarking code and sampling data. All Console methods become no-ops in exported plugins, so you can leave debugging calls in production code without performance cost. Console methods are safe to call from any thread, including the audio thread.

The assertion methods (`assertTrue`, `assertEqual`, `assertIsDefined`, `assertIsObjectOrArray`, `assertNoString`, `assertLegalNumber`) are commonly used as guard clauses in utility functions and module construction pipelines. They surface programming errors immediately during development while being stripped from exported builds. The `stop()` method provides conditional breakpoints that halt execution in the IDE, and `blink()` flashes a visual indicator at the calling line without pausing. Benchmarking with `startBenchmark()` and `stopBenchmark()` measures elapsed time for performance analysis. The data sampling system (`startSampling()` and `sample()`) records labeled snapshots for inspection in the code editor, useful when debugging iterative algorithms or state machines.

## Common Mistakes

- **Wrong:** `if (!isDefined(obj)) return;` in a function where `obj` must always exist  
  **Right:** `Console.assertIsDefined(obj);`  
  *Silent early returns hide bugs. If `obj` being undefined is a programming error (not a valid state), an assertion surfaces it immediately during development while being stripped in release builds.*

- **Wrong:** Wrapping `Console.print()` calls in `if (Engine.isHISE())` guards  
  **Right:** Call `Console.print()` directly without guards  
  *Console methods are already no-ops in exported plugins. Manual guards add clutter with no benefit.*

- **Wrong:** `Console.stopBenchmark()` without calling `Console.startBenchmark()` first  
  **Right:** Call `Console.startBenchmark()` before `Console.stopBenchmark()`  
  *`stopBenchmark` throws a script error if the benchmark was never started.*

- **Wrong:** Calling `Console.sample()` without `Console.startSampling()`  
  **Right:** Call `Console.startSampling("id")` before `Console.sample()`  
  *Without an active session, `sample()` logs a warning and skips recording. The warning is only shown once.*
