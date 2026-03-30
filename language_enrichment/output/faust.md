---
title: Faust in HISE
description: "Integrating the Faust DSP language into HISE via the core.faust scriptnode node"

guidance:
  summary: >
    Guide for using the Faust functional DSP language inside HISE. Covers the
    core.faust scriptnode node, automatic compilation during development,
    parameter handling (automatic slider/button mapping to scriptnode
    parameters, MIDI zone auto-mapping for freq/gate/gain), channel count
    resolution (a common pain point - Faust output count must equal HISE
    channel count), modulation output via bargraph objects, external data
    limitations, the static export workflow for compiled plugins, and
    comprehensive differences from standard Faust. Assumes familiarity
    with scriptnode basics.
  concepts:
    - Faust
    - core.faust
    - compilation
    - parameter mapping
    - MIDI zone
    - freq gate gain
    - channel count
    - modulation output
    - bargraph
    - static export
    - DLL compilation
  prerequisites:
    - scriptnode
  complexity: intermediate
---

[Faust](https://faust.grame.fr) is a functional programming language for real-time audio signal processing. HISE integrates Faust through the $SN.core.faust$ scriptnode node, which compiles your code automatically during development and exports it as compiled C++ for final plugin builds.

Unlike the $LANG.rnbo$ integration (which requires a manual export/compile cycle), the Faust workflow is tightly integrated: edit your `.dsp` file in the HISE code editor, and changes compile automatically. This makes Faust particularly suited for iterative DSP development within scriptnode.


## Getting Started

### 1. Create a Faust Node

Add a `core.faust` node to your scriptnode network. The node's header bar provides:

- **Class selector** (ComboBox) — choose or create a Faust source file
- **Add/Edit/Reload buttons** — manage source files
- **Modulation output dragger** — if modulation is enabled

### 2. Edit the Source File

Faust source files live in `DspNetworks/CodeLibrary/faust/`. When you create a new class, HISE generates a default template:

```faust
import("stdfaust.lib");
process = _, _;
```

This is a stereo passthrough. The `process` expression defines the DSP algorithm — its input/output signature determines the channel count.

### 3. Compile and Listen

Save the file (or press the compile button). HISE compiles the code automatically and the node starts processing audio immediately.

> [!Tip:Use the built-in editor] HISE includes a Faust code editor with syntax highlighting and error reporting. You can also use an external editor by enabling the `FaustExternalEditor` setting.


## Parameter Handling

Faust UI elements (sliders, buttons, entries) automatically become scriptnode parameters when the node compiles. The mapping is direct: each Faust UI widget creates one parameter.

```faust
import("stdfaust.lib");
gain = hslider("Gain", 0, -96, 0, 0.1);
freq = hslider("Frequency", 1000, 20, 20000, 1);
process = _ * ba.db2linear(gain) : fi.lowpass(2, freq) <: _, _;
```

This creates a node with two parameters: **Gain** and **Frequency**, each with the range and step size defined in the Faust code.

### MIDI Auto-Mapping

Parameters named `freq`, `gate`, or `gain` are automatically mapped to MIDI note-on/note-off events:

| Parameter name | MIDI mapping |
| --- | --- |
| `freq` | Note frequency (Hz) from note number |
| `gate` | 1.0 on note-on, 0.0 on note-off |
| `gain` | Velocity-scaled gain |

This enables polyphonic Faust instruments without explicit MIDI handling:

```faust
import("stdfaust.lib");
freq = hslider("freq", 440, 20, 20000, 1);
gate = button("gate");
gain = hslider("gain", 1, 0, 1, 0.01);
process = os.osc(freq) * gate * gain <: _, _;
```

> [!Warning:Use exact parameter names for MIDI mapping] The names must be exactly `freq`, `gate`, and `gain` (lowercase). Other names like `frequency` or `volume` will not auto-map to MIDI.

### Parameter Persistence

When the Faust code recompiles (after an edit), parameter values are preserved across the compilation cycle.


## Channel Count Resolution

This is the most common source of errors when working with Faust in HISE. The rules are strict:

1. **Faust output count must equal HISE channel count** — if your scriptnode network is stereo (2 channels), your Faust `process` must output exactly 2 channels
2. **Faust input count must be less than or equal to HISE channel count** — you can have fewer inputs than outputs (e.g., a mono-to-stereo effect), but not more

A mismatch produces a channel count error that shows the expected and actual channel counts.

### Common Patterns

```faust
// Stereo passthrough (2 in, 2 out)
process = _, _;

// Mono-to-stereo (1 in, 2 out) — valid in a stereo context
process = _ <: _, _;

// Stereo effect (2 in, 2 out)
process = _, _ : + : fi.lowpass(2, 1000) <: _, _;
```

> [!Warning:Match your channel count to the scriptnode context] If your Faust code outputs 1 channel but the scriptnode network expects 2, you'll get a channel mismatch error. Use `<: _, _` to split a mono signal to stereo.


## Modulation Output

Faust `hbargraph` and `vbargraph` objects become modulation sources that can drive any scriptnode parameter. Up to 4 modulation outputs are supported by default (configurable up to 16 by setting `HISE_NUM_MAX_FAUST_MOD_SOURCES` in your project's preprocessor definitions).

```faust
import("stdfaust.lib");
process = _ : *(0.5) : attach(_, abs : hbargraph("mod", 0, 1));
```

The bargraph value is sent as a normalised modulation signal (0.0 to 1.0) to connected modulation targets.

### Periodic Modulation

For once-per-buffer modulation updates (matching scriptnode's `fix_block` resolution), use `inport` objects:

- `inport` with tag `postrender` — receives a bang after each audio buffer
- `inport` with tag `blocksize` — called when processing specs change, provides the current block size

This is consistent with how modulation works in the rest of scriptnode.


## External Data

External data slots (Tables, SliderPacks, AudioFiles) are **not currently supported** in the Faust integration.

If you need to use lookup tables or audio file data in your DSP, consider:
- Using a $LANG.cpp-dsp-nodes$ node with `setExternalData()` support
- Processing the data in HiseScript and passing results as parameters
- Using Faust's built-in `rdtable` / `rwtable` for compile-time tables


## Static Export Workflow

During development, Faust code compiles automatically when you save. When you export your HISE project as a plugin, Faust code is transpiled to C++ and compiled into the plugin binary:

1. **Export as DLL** — Go to **Export > Compile DSP Networks as DLL**. HISE transpiles each `.dsp` file to C++ and generates the necessary wrapper code
2. **Channel count** — Determined automatically from your Faust `process` expression's output count
3. **DLL compilation** — The generated code is compiled alongside any other third-party nodes

> [!Warning:Export before deploying] Faust code must be exported to C++ before building the final plugin. The live compilation used during development is not available in exported plugins.

### Requirements

- **Faust version** 2.74.6 or later
- **Faust installation** — Configure the `FaustPath` setting to point to your Faust installation, or use the bundled distribution at `tools/faust/`
- **Standard libraries** — The Faust standard libraries (`stdfaust.lib`, etc.) must be accessible via the configured path


## Differences from Standard Faust

| Feature | Standard Faust | HISE Integration | Notes |
| --- | --- | --- | --- |
| Soundfile support | `soundfile` primitive | Not supported | |
| External data (tables, audio) | Via `soundfile` or `waveform` | Not supported | Use Faust's built-in `rdtable`/`rwtable` for compile-time tables |
| Channel count | Flexible | Must match HISE context | Output count = HISE channels; input count ≤ HISE channels |
| Polyphony | `declare options "[nvoices:N]"` | Use HISE polyphony | Faust polyphony declarations are ignored |
| MIDI mapping | Manual via `freq`/`gate`/`gain` convention | Automatic when names match | Same convention, but HISE auto-maps without extra setup |
| UI widgets | Rendered by Faust architecture | Become scriptnode parameters | No Faust UI rendering — widgets map to parameter controls |
| Bargraph output | Display only | Becomes modulation source | `hbargraph`/`vbargraph` drive scriptnode modulation |
| Processing model | In-place possible | Input buffer copied | Wrapper copies input to avoid conflicts |
| Compilation | `faust` CLI or libfaust | Automatic in IDE; static C++ at export | Transparent to the user |
| Standard libraries | Full access | Full access | `import("stdfaust.lib")` works normally |


## Limitations

- No soundfile or external data support — use $LANG.cpp-dsp-nodes$ if you need table/audio file access
- Channel count must exactly match the scriptnode context (a frequent source of errors for new users)
- Input buffer is always copied (not in-place processing), which uses extra memory
- Maximum 4 modulation outputs by default (up to 16 with preprocessor override)
- Faust polyphony settings are ignored — use HISE's voice management instead
- Parameter names `freq`, `gate`, `gain` are reserved for MIDI auto-mapping — avoid these names for non-MIDI parameters


## What's Next

**See also:** $SN.core.faust$ -- the scriptnode node reference, $LANG.rnbo$ -- alternative external DSP integration, $LANG.cpp-dsp-nodes$ -- full C++ DSP node development, $LANG.snex$ -- HISE's built-in JIT-compiled DSP language
