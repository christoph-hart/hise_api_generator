---
title: Faust
description: "A node that compiles and runs Faust DSP code with automatic parameter and modulation output mapping."
factoryPath: core.faust
factory: core
polyphonic: true
tags: [core, faust, custom-dsp]
cpuProfile:
  baseline: variable
  polyphonic: true
  scalingFactors: []
seeAlso:
  - { id: "core.snex_node", type: alternative, reason: "Custom DSP using SNEX instead of Faust" }
commonMistakes:
  - title: "Mismatched channel count causes error"
    wrong: "Writing Faust code with a different number of output channels than the scriptnode context provides"
    right: "Ensure the Faust code's output channel count matches the current scriptnode channel configuration."
    explanation: "The node validates that the Faust output channel count matches the HISE channel count. A mismatch produces an error. Faust input channels may be fewer than HISE channels."
llmRef: |
  core.faust

  Compiles and runs Faust DSP code at runtime. Parameters are created automatically from Faust UI elements (sliders, buttons, nentry). Modulation outputs are created from bargraph elements. Supports polyphony with one DSP instance per voice.

  Signal flow:
    audio in -> Faust compute() -> audio out
    (optional) MIDI in -> Faust UI zones
    (optional) bargraph elements -> modulation outputs

  CPU: variable (depends on Faust code), polyphonic

  Parameters:
    All parameters are defined by the Faust code's UI elements.

  When to use:
    - Porting existing Faust algorithms into HISE
    - Writing DSP in the Faust functional language
    - Algorithms that benefit from Faust's automatic optimisation

  Common mistakes:
    - Faust output channel count must match HISE channel count

  See also:
    [alternative] core.snex_node -- custom DSP via SNEX
---

The Faust node compiles and runs [Faust](https://faust.grame.fr/) DSP code within scriptnode. Faust is a functional DSP programming language -- the node handles compilation, parameter discovery, and audio routing automatically. Parameters are created from Faust UI elements (sliders, buttons, numeric entries) and modulation outputs are created from bargraph elements, so the node's interface adapts entirely to the Faust code.

The node supports polyphony, with one independent Faust DSP instance per voice. MIDI events are forwarded to the Faust code if it defines MIDI zones. The `classId` property selects which Faust source file to compile.

## Signal Path

::signal-path
---
glossary:
  functions:
    faustCompute:
      desc: "Runs the compiled Faust DSP algorithm on a block of audio"
---

```
// core.faust - Faust DSP code execution
// audio in -> audio out (+ optional MIDI, mod outputs)

process(input) {
    // Parameters mapped from Faust UI elements
    // (sliders, buttons, nentry)

    output = faustCompute(input)

    // bargraph elements become modulation outputs
}
```

::

## Parameters

All parameters are defined dynamically by the Faust code's UI elements. The node itself has no built-in parameters. When the Faust code is recompiled, parameters are remapped automatically and their values are preserved across recompilation.

## Notes

HISE must be built with Faust support enabled for this node to be available. The Faust code can be compiled via either an LLVM backend (faster execution) or an interpreter backend (no LLVM dependency).

The Faust output channel count must match the scriptnode channel configuration. The input channel count may be smaller -- unused input channels are simply not passed to the Faust code.

**See also:** $SN.core.snex_node$ -- custom DSP using SNEX instead of Faust
