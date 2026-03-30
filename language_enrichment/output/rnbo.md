---
title: RNBO in HISE
description: "How to import RNBO patches as scriptnode DSP nodes"

guidance:
  summary: >
    Guide for importing DSP patches from Cycling '74 RNBO into HISE. Covers
    the export settings in RNBO, the HISE template builder for generating
    C++ wrapper code, the DLL compilation workflow, and advanced features
    including modulation output, tempo syncing, and complex data types
    (Tables, SliderPacks, AudioFiles). Assumes familiarity with scriptnode
    and the general concept of third-party C++ node integration.
  concepts:
    - RNBO
    - Max/MSP
    - third-party DSP
    - DLL compilation
    - scriptnode integration
    - modulation output
    - complex data types
    - template builder
  prerequisites:
    - scriptnode
    - cpp-dsp-nodes
  complexity: intermediate
---

[RNBO](https://rnbo.cycling74.com) is a subset of Max/MSP that exports DSP algorithms as portable C++ code. The RNBO integration in HISE lets you compile an RNBO patch into a scriptnode node, usable either inside a scriptnode network or as a standalone Hardcoded Effect module.

If you're familiar with the $LANG.faust$ or $LANG.cpp-dsp-nodes$ integration, the RNBO workflow follows the same pattern: export C++ from your authoring tool, generate a wrapper with the HISE template builder, compile a DLL, and use the node.

The integration supports:

- MIDI communication (note on/off, CC)
- Tempo syncing (transport start/stop, BPM)
- Modulation output via `outport` with the `mod` tag ID
- HISE complex data types (Tables, SliderPacks, AudioFiles) as external buffers


## Getting Started

### 1. Export from RNBO

Open your patch in RNBO and navigate to the Export menu. Configure:

| Setting | Value | Notes |
| --- | --- | --- |
| Output directory | `DspNetworks/ThirdParty/src` | Where HISE looks for the exported code |
| ExportName | `your_patch_name` | Must be a valid identifier (see below) |
| ClassName | `your_patch_name` | Must match ExportName exactly |
| Polyphony | Disabled | RNBO polyphony must be off — use HISE polyphony instead |

A valid identifier starts with a letter or underscore, contains only letters, digits, and underscores, and is not a reserved keyword (`if`, `while`, `public`, etc.).

Click Export to generate the C++ files in the output directory.

### 2. Create the HISE Wrapper

1. Open HISE and go to **Tools > Create Template for RNBO Patch**
2. Select the exported C++ file from the dropdown
3. Configure channels, polyphony, and other options (each has a help button)
4. Press **OK** to generate the wrapper code in `ThirdParty/`

### 3. Compile and Use

1. Export the DLL (**Export > Compile DSP Networks as DLL**)
2. Restart HISE
3. The RNBO node appears in scriptnode's node browser, ready to use


## Modulation Output

To send a modulation signal from your RNBO patch to any scriptnode parameter:

1. Enable **Modulation** in the template builder
2. Add an `outport` object in your RNBO patch with the tag `mod`
3. For periodic modulation (once per audio buffer), add an `inport` with the tag `postrender` — it receives a bang after each buffer is processed
4. To know the buffer size, add an `inport` with the tag `blocksize` — it fires when processing specs change

This matches how modulation works in scriptnode: the modulation resolution is controlled by `fix_block` containers.

### Example: Peak Detector (equivalent to `core.peak`)

The RNBO patch feeds a signal cable into `peakamp~`, uses `postrender` for once-per-buffer updates, and sends the peak value through an `outport` with the `mod` tag.


## Complex Data Slots

HISE's three main UI data types — Table, SliderPack, and AudioFile — all operate on float arrays that can be shared with RNBO patches.

### Setup

1. In RNBO, add a `buffer~` object with:
   - A unique `name` attribute (use a valid C++ identifier)
   - The `external` attribute set to `1`
2. In the HISE template builder, enter the buffer name into the appropriate field (Table IDs, SliderPack IDs, or AudioFile IDs)

**Example:** Add `buffer~ @name my_table @external 1` in RNBO, then enter `my_table` in the Table IDs field. After compilation, the node exposes a table slot that you can connect to your interface.

### Audio File Limitations

RNBO expects interleaved audio data (all samples of one channel written consecutively). The wrapper duplicates the buffer and converts the format, which **doubles memory usage**. Multi-format audio files (SFZ, Samplemap) are not supported — only single audio files per slot.


## Differences from Standard RNBO

| Feature | Standard RNBO | HISE Integration | Notes |
| --- | --- | --- | --- |
| Polyphony | Configurable in export | Must be disabled | Use HISE's polyphonic scriptnode containers instead |
| Export name | Any string | Must be a valid C++ identifier | No spaces, no leading digits, no reserved words |
| Audio file format | Interleaved or deinterleaved | Interleaved only | Wrapper converts format; doubles memory usage |
| Multi-format audio | Supported | Not supported | One audio file per slot only |
| Modulation output | Via `outport` | Via `outport` with `mod` tag | Must use specific tag ID for HISE integration |
| Tempo sync | Automatic | Supported | Transport start/stop and BPM sync work |


## Limitations

- RNBO polyphony must be disabled — polyphonic processing is handled by HISE's voice management
- Audio file slots use double memory due to format conversion
- No SFZ or Samplemap support for audio data
- The ExportName and ClassName must be identical valid identifiers


## What's Next

**See also:** $LANG.faust$ -- alternative DSP language integration with live JIT compilation, $LANG.cpp-dsp-nodes$ -- writing custom C++ nodes directly
