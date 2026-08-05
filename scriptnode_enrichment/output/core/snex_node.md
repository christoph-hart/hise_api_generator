---
title: core.snex_node
description: "A generic SNEX node with the complete callback set for custom audio processing."
factoryPath: core.snex_node
factory: core
polyphonic: true
tags: [core, snex, custom-dsp]
cpuProfile:
  baseline: variable
  polyphonic: true
  scalingFactors: []
forumReferences:
  - { tid: 4364, reason: "SNEX export workflow: wrap into DSP network, compile, freeze" }
seeAlso:
  - { id: "core.snex_shaper", type: alternative, reason: "Simpler SNEX interface for waveshaping only" }
  - { id: "core.snex_osc", type: alternative, reason: "SNEX interface specialised for oscillators with built-in frequency tracking" }
  - { id: "core.faust", type: alternative, reason: "Alternative custom DSP using Faust language instead of SNEX" }
commonMistakes:
  - title: "Sharing state between voices"
    wrong: "Storing voice-specific state in ordinary SNEX member variables inside a polyphonic network"
    right: "Store voice-specific state in PolyData so each rendered voice has an independent value."
    explanation: "The SNEX class receives the network voice count. Ordinary members are shared, while PolyData selects the current voice during polyphonic rendering."
  - title: "SNEX JIT compiler is not included in exported plugins"
    wrong: "Exporting a plugin that uses core.snex_node (or cable_expr, math.expr) without compiling to a C++ DLL first"
    right: "Wrap the SNEX node into a sub-network using the 'Wrap into DSP Network' toolbar action, then compile it with 'Compile DSP Networks'. The frozen (snowflake) icon confirms the compiled version is active."
    explanation: "The SNEX JIT compiler is not part of the exported plugin binary. Any node that uses SNEX (including cable_expr and math.expr) must be compiled to a C++ DLL before export, or it will be replaced by a silent dummy in the shipped plugin."
llmRef: |
  core.snex_node

  A generic SNEX node that delegates all audio processing to user-written SNEX code compiled at runtime. Supports the full callback set: prepare, reset, process, processFrame, and handleHiseEvent. Parameters and complex data slots are defined dynamically by the SNEX code.

  Signal flow:
    audio in + MIDI in -> SNEX process callbacks -> audio out
    (optional) -> modulation out (normalised 0-1)

  CPU: variable (depends on user SNEX code), polyphonic

  Parameters:
    All parameters are user-defined in the SNEX code (up to 16).

  When to use:
    - Custom audio processing that cannot be built from existing nodes
    - Prototyping DSP algorithms with JIT compilation
    - Polyphonic DSP that manages per-voice state with PolyData

  Common mistakes:
    - Use PolyData for state that must remain independent per voice
    - SNEX JIT not in exported plugins -- must wrap and compile to C++ DLL first

  Forum references: tid:4364 (export workflow: wrap, compile, freeze)

  See also:
    [alternative] core.snex_shaper -- waveshaping-only SNEX interface
    [alternative] core.snex_osc -- oscillator SNEX interface with frequency tracking
    [alternative] core.faust -- custom DSP via Faust language
---

The SNEX node is a general-purpose container for custom DSP written in [SNEX]($LANG.snex$). It provides the complete set of processing callbacks, giving full control over audio processing, MIDI event handling, and optionally modulation output. The SNEX code is compiled at runtime, so changes take effect immediately without restarting.

Unlike the more specialised [core.snex_shaper]($SN.core.snex_shaper$) and [core.snex_osc]($SN.core.snex_osc$), this node imposes no constraints on what the SNEX code does. It receives audio input, MIDI events, and any user-defined parameters, then delegates everything to the compiled SNEX callbacks.

The wrapper has no separate polyphonic C++ instantiation because it holds no voice-count-dependent state itself. The compiled SNEX class receives the root network's voice count, so it can use `PolyData` for independent per-voice state in a polyphonic network. Ordinary SNEX members remain shared between voices.

## Signal Path

::signal-path
---
glossary:
  functions:
    snexProcess:
      desc: "Delegates to the user's compiled SNEX process callback"
    handleModulation:
      desc: "Optional callback that produces a normalised modulation output (0-1)"
---

```
// core.snex_node - custom DSP via SNEX code
// audio + MIDI in -> audio out (+ optional mod out)

process(input) {
    // All processing defined by user SNEX code
    output = snexProcess(input)

    // If handleModulation() is defined in the SNEX code:
    modOutput = handleModulation()
}
```

::

## Parameters

All parameters are defined dynamically by the user's SNEX code. The node itself has no built-in parameters. Up to 16 parameters can be declared in the SNEX class.

### Required callbacks

All five callbacks are required; compilation fails if any cannot be resolved.

```cpp
void prepare(PrepareSpecs ps);
void reset();
void handleHiseEvent(HiseEvent& e);
template <typename T> void process(T& data);
template <int C> void processFrame(span<float, C>& data);
```

`prepare` runs when processing specifications change and is the place to initialise sample-rate or block-size-dependent state. `reset` clears processing state after preparation and when the processing pipeline resets. `handleHiseEvent` receives HISE/MIDI events. `process` handles block processing, while `processFrame` handles frame-processing contexts.

### Optional integration callbacks

```cpp
void setExternalData(const ExternalData& d, int index);
int handleModulation(double& value);
double getPlotValue(int getMagnitude, double freqNormalised);
```

`setExternalData` receives tables, audio files, and other complex data. `handleModulation` writes a normalised modulation value and returns `1` when it changed or `0` otherwise. `getPlotValue` supplies a filter response display and requires a `data::filter_node_base` implementation initialised with `SNEX_INIT_FILTER`.

Parameters use `template <int P> void setParameter(double value)`; `P` is the parameter index. Parameter callbacks can run at audio modulation rate, so they must remain suitable for the audio thread.

The `ClassId` property selects which SNEX class to compile. Parameters, complex data slots, and modulation output are all discovered from the compiled SNEX code -- nothing is configured on the node itself.

### Export workflow

The SNEX JIT compiler is not included in exported plugin binaries. To use a SNEX node in a shipping plugin:

1. Use the **Wrap into DSP Network** action in the scriptnode toolbar to create an encapsulated sub-network.
2. Run **Compile DSP Networks** to generate the C++ DLL.
3. After reloading, the frozen (snowflake) icon confirms the compiled version is active.

This applies to all SNEX-based nodes, including `cable_expr`, `math.expr`, and parameter expression nodes.

**See also:** $SN.core.snex_shaper$ -- simpler SNEX interface for waveshaping only, $SN.core.snex_osc$ -- SNEX interface specialised for oscillators with built-in frequency tracking, $SN.core.faust$ -- alternative custom DSP using Faust language instead of SNEX
