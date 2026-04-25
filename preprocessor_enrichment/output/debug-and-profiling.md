---
title: Debug & Profiling
description: Diagnostic overlay controls — CPU and peak meters, host info, buffer warnings, plot data, startup logs, glitch detection, and Perfetto hooks.
---

Preprocessors in this category control the diagnostic layer built into every HISE plugin: CPU meters, peak meters, host info readouts, buffer-size warnings, plotter data, startup logs and the built-in glitch detector. Most are on by default so that developers can diagnose problems during authoring; switching them off in a release build trims a small amount of per-block overhead and hides internal status displays from end users. One flag in this group aborts the plugin outright on the next audio glitch, which is only useful in test harnesses. The Perfetto-style profiling toolkit is wired up here as well.

### `ENABLE_ALL_PEAK_METERS`

Collects output-level data on every module so that scripted peak meters keep working in an exported plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Every modulator, effect and sound generator writes its current output magnitude into a per-module meter slot while this flag is on, which is what feeds the module header meters in the HISE IDE, the MatrixPeakMeter tile in an exported plugin and every timer-based getCurrentLevel call on a modulator. Turning it off saves the per-block magnitude scan on every module in the signal path and shrinks the per-module state, but any scripted peak readback or meter tile will read zero and modulator graphs like the animated AHDSR envelope stop updating. Needed in exported plugins because the default project template disables it to save CPU.
> Add `ENABLE_ALL_PEAK_METERS=1` to the ExtraDefinitions field before exporting if your plugin uses peak meters, scripted level readback or modulator graph displays, otherwise they will read zero at runtime.

**See also:** $MODULES.LFO$ -- getCurrentLevel returns zero in exported plugins unless per-module peak collection is enabled, $MODULES.AHDSR$ -- animated envelope graph display relies on the per-module peak collection, $MODULES.Convolution$ -- wet input and output magnitudes used by the module meter are only scanned when this flag is on, $SN.core.peak$ -- MatrixPeakMeter tile and scriptnode peak readback fall back to zero when per-module collection is off, $PP.ENABLE_PEAK_METERS_FOR_GAIN_EFFECT$ -- companion flag for the simple gain effect which scans its output magnitude through a separate switch

### `ENABLE_CPU_MEASUREMENT`

Measures per-block rendering time so the CPU meter and sample loading thread report live load figures.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Wraps every audio render pass in a high-resolution benchmark so that the main CPU usage tile and the sample-loader busy-ratio readout have real numbers to display. The sampler streaming thread also uses the same timing hooks to report how much of each sample load window was spent doing work. Disabling it removes two high-resolution timer reads per render block and one more per streaming job, which is measurable on very small buffer sizes but usually negligible; the trade-off is that the CPU meter reads zero and the streaming diagnostics report no busy ratio.

### `ENABLE_HOST_INFO`

Pulls transport and tempo information from the host into the engine on every audio block.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Queries the DAW playhead each render block to update the engine's tempo, playing position, time signature and grid tick information so that tempo-synced modulators, transport-aware scripts and the TransportHandler callbacks receive live values. Turning this off skips the playhead query entirely; the engine then falls back to its internal clock and any tempo-synced module will freeze at its last known BPM. Only disable it for a very lean utility build where the plugin must not react to host transport at all, because the cost of the query is small compared to what downstream modules do with the data.

### `ENABLE_PEAK_METERS_FOR_GAIN_EFFECT`

Collects post-gain output magnitudes on the Simple Gain effect so its meter reads live values.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Scans the left and right output magnitude of the Simple Gain effect after the gain stage has been applied, which feeds the module's output meter and any scripted getCurrentLevel call against it. This is split out from the global peak meter flag because the Simple Gain effect is used heavily on the master chain and in voice effect chains, so exporting without it can save the magnitude scan on every instance. Turning it off does not affect any other effect, only the Simple Gain.
> Read together with the global peak meter flag: disabling the global flag still leaves the Simple Gain meter alive if this one is on, and vice versa.

**See also:** $MODULES.SimpleGain$ -- output magnitude scan used by the module meter is gated by this flag, $PP.ENABLE_ALL_PEAK_METERS$ -- global peak meter switch that every other module uses; this flag carves out the Simple Gain effect separately

### `ENABLE_STARTUP_LOG`

Writes a timestamped plain-text startup log to the user's desktop while the plugin initialises.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Installs a lightweight logger that appends every major initialisation step (preset load, sample scan, scriptnode compile, UI build) to a StartLog.txt file on the user's desktop, together with the elapsed milliseconds since the previous entry. Useful when debugging a plugin that fails on a customer machine where no debugger or console is available, because the file survives a crash and shows exactly which step hung. Carries essentially no overhead during normal operation (one file append per milestone) but writes to the desktop unconditionally, so do not ship a release build with this enabled.
> The log file is always created at the same path on the desktop and is overwritten on every startup, so remind users to grab the file before relaunching the plugin.

### `HISE_COMPLAIN_ABOUT_ILLEGAL_BUFFER_SIZE`

Shows an overlay message when the host asks for a buffer size that is not a multiple of the event raster.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Every modulation block and MIDI event timestamp in HISE is aligned to the event raster grid, so any host buffer size that is not an integer multiple of that raster forces the engine to pad the block internally and can cause subtle timing drift. With this flag on, the engine pops up a user-facing error overlay the moment such a buffer size is negotiated, which catches misconfigured audio devices during development. Turn it off when shipping a plugin that is expected to run on fixed hardware where the buffer size is known to be compatible and the overlay would only confuse end users.

**See also:** $PP.HISE_EVENT_RASTER$ -- defines the raster divisor that the buffer size must be a multiple of for the check to pass, $PP.HISE_MAX_PROCESSING_BLOCKSIZE$ -- caps the internal block size used after rastering and must itself stay a multiple of the event raster

### `HISE_INCLUDE_PROFILING_TOOLKIT`

Compiles the in-engine profiler that records thread, scriptnode and script execution traces.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | yes | no |

Enables the full profiling toolkit: the Threads.startProfiling scripting API that captures a base64-encoded timeline, the per-node execution timing inside scriptnode, the paint-function timing on ScriptLookAndFeel, the broadcaster send trace and the script engine's sample/startSampling debug hooks. Without this flag the profiler entry points still compile but behave as no-ops or throw a script error, so calls from HISEScript fail silently in an exported plugin. Leave this off for release builds because the timeline collection adds measurable overhead to every instrumented code path and the recorded data is only useful inside the HISE IDE or when exported back out for analysis.
> Read from the project's Extra Definitions at runtime, so a scripted profiling call can check the flag and warn the user when the compiled plugin was not built with it.

**See also:** $API.Threads.startProfiling$ -- Threads.startProfiling throws a script error unless this flag is enabled, $API.Console$ -- Console.startSampling and Console.sample become no-ops when the profiling toolkit is not compiled in, $API.Broadcaster$ -- sendMessage instrumentation and per-callback timing collection are only active with this flag, $API.ScriptLookAndFeel$ -- per-paint-routine timing for LAF callbacks requires the profiling toolkit

### `HISE_SCRIPT_SERVER_TIMEOUT`

Timeout in milliseconds for every HTTP request issued by the scripting server and download APIs.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `10000` | no | no |

Sets the connection and read timeout used by every HTTP call the engine makes on behalf of a script, which covers Server.callWithGET and callWithPOST, Server.isOnline, the Download and background-task HTTP helpers, and the internal update checker. The default of 10000 ms is a reasonable balance for typical authentication pings and small metadata requests; raise it to 30000 or more if the plugin talks to a slow REST endpoint or downloads larger responses synchronously, and lower it only if the script polls a URL fast enough that a stuck request must not block the script thread. The value is baked in at compile time, so overriding it requires an ExtraDefinitions entry rather than a runtime API.

**See also:** $API.Server$ -- every callWithGET, callWithPOST and isOnline request uses this timeout, $API.Download$ -- HTTP download resume and start use this as the connection timeout

### `USE_GLITCH_DETECTION`

Instruments performance-critical audio functions with a scoped timer that logs when they overrun the buffer budget.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Wraps marked audio-thread functions in a stack-allocated timer that logs a warning to the system logger whenever the function runs longer than the current buffer budget, with deduplication so that a single glitch only produces one log entry even if the call appears multiple times in the stack. Useful during development to locate which module is responsible for an audible drop-out, but the per-scope timer and identifier bookkeeping add non-trivial overhead on the audio thread, which is why the default project template disables it for exported plugins. Leave this off for release builds.

## Deprecated

These macros are still defined so old projects keep compiling, but no code reads them. Setting them has no effect.

### `CRASH_ON_GLITCH`

Historical switch for crashing the plugin on the first audio drop-out or burst above +36 dB.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

The original intent was to hard-crash the application as soon as the glitch detector spotted an output sample louder than +36 dB or a buffer-level drop-out, so that a debugger attached to the process would break at the exact stack frame responsible. The macro is still defined but no code path reads it anywhere, so toggling it has no effect on how glitches or bursts are handled at runtime. It is kept around so that older user projects which list it in their ExtraDefinitions field keep compiling.

### `ENABLE_PLOTTER`

Historical switch for the per-modulator plotter ring buffer used by the IDE's Plotter panel.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

The original purpose was to gate the sample collection that fed the IDE-side Plotter panel so that exported plugins could skip the per-sample push onto the plot ring buffer. The macro is still defined but no code reads it anywhere in the current engine; the project template still writes it to keep older ExtraDefinitions lists compiling, but toggling the value has no effect on CPU load or on whether the Plotter panel updates. It is kept only so that legacy user projects which list it keep working.
