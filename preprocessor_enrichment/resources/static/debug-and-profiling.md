---
description: Diagnostic overlay controls — CPU and peak meters, host info, buffer warnings, plot data, startup logs, glitch detection, and Perfetto hooks.
---

Preprocessors in this category control the diagnostic layer built into every HISE plugin: CPU meters, peak meters, host info readouts, buffer-size warnings, plotter data, startup logs and the built-in glitch detector. Most are on by default so that developers can diagnose problems during authoring; switching them off in a release build trims a small amount of per-block overhead and hides internal status displays from end users. One flag in this group aborts the plugin outright on the next audio glitch, which is only useful in test harnesses. The Perfetto-style profiling toolkit is wired up here as well.
