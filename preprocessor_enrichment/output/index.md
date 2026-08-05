---
title: Preprocessor Reference
description: Compile-time macros that change HISE behaviour project-wide
---

HISE preprocessors are compile-time constants that are evaluated when the compiler creates the binaries (either for HISE or your plugin). They change engine behaviour, array sizes, optional library inclusion and bit-exact audio paths at build time.

### How to use the preprocessors

You can use these preprocessors in two ways:

1. Modify the source code & recompile HISE. This is the brute force option and let's you permanently alter the behaviour of HISE. Note that this basically makes you fork HISE so whenever you update HISE you will have to perform this step again so it's only recommended if there is no other solution.
2. Add per-project settings using the ExtraDefinitions field. Every project info file has fields that allow you to set the preprocessors for each project and platform / OS. This is highly recommended for preprocessors that change between projects as recompiling HISE whenever you switch projects would not be very feasible. 

### Hot Reloading

Note that there are a few selected preprocessors that "emulate" the value from the extra definitions field in the HISE IDE so that you don't have to recompile it. The most commonly used example would be the preprocessors that define the amount of modulation slots for each hardcoded / scriptnode module: whenever you change this preprocessor, you just have to unload / load the current patch for the values to be synced to the exact value that will be used for compilation. 

This is obviously not possible with all preprocessors (eg. the inclusion of proprietary SDKs like the NKS SDK from Native Instruments cannot be "emulated" like this) and some preprocessors change internal data structures which would create too much overhead.

Preprocessors that support this functionality are marked with the *Hot Reloading: Yes** property in this reference. Note that you might have to reload the current patch (or even HISE) for it to be consistently applied as most of these values are cached at initialisation.

### Auto Config Flag

This flag means that the export procedure that happens when you compile your plugin will at some point touch this preprocessor and set it to its appropriate value, so you will most likely never have to put them into the ExtraDefinitions field. This is either directly mapped to a project settings (eg. `HISE_ENABLE_MIDI_INPUT_FOR_FX` directly represents the **Enable Midi Input For Effect Plugins** setting) or derived from other settings (eg. the `HISE_NUM_PLUGIN_CHANNELS` macro is derived from the amount of output channels of your master chain).

## Categories

- [Third-Party Modules](/v2/reference/preprocessors/third-party-modules): Optional third-party libraries and SDK integrations — Loris, rLottie, RTNeural, pitch detection, FFTW3, IPP, xsimd, MuseHub, Beatport, NKS.
- [Preset & State](/v2/reference/preprocessors/preset-and-state): Exported plugin state handling — AppData location, asset baking, first-launch folders, preset overwrite policy, tempo persistence, undo coalescing.
- [Debug & Profiling](/v2/reference/preprocessors/debug-and-profiling): Diagnostic overlay controls — CPU and peak meters, host info, buffer warnings, plot data, startup logs, glitch detection, and Perfetto hooks.
- [Licensing & Expansions](/v2/reference/preprocessors/licensing-and-expansions): Copy protection, activation, and storefront integrations — unlocker overlays, machine-id fingerprints, Beatport and MuseHub hooks, expansion packs.
- [Plugin Type](/v2/reference/preprocessors/plugin-type): Plugin type and host bus configuration — instrument vs effect, audio input routing, mono layout, and FX-build sound generator handling.
- [Sampler & Streaming](/v2/reference/preprocessors/sampler-and-streaming): Streaming sampler backend and sample-installation UX — monolith access, preload threshold, release start, and SamplesNotInstalled overlay buttons.
- [UI & Graphics](/v2/reference/preprocessors/ui-and-graphics): Plugin UI code-path toggles — OpenGL rendering, bundled Lato font, alert look-and-feel, floating tiles, registration overlay, splash screen.
- [Audio Processing](/v2/reference/preprocessors/audio-processing): Block-level audio engine knobs — modulation raster, processing block size, voice culling, tempo-sync range, and suspended-voice handling.
- [Automation & Macros](/v2/reference/preprocessors/automation-and-macros): Macro control count and MIDI automation storage — how many macros exist, whether they are host parameters, and how CC mappings persist.
- [DSP & Filters](/v2/reference/preprocessors/dsp-and-filters): Module-specific DSP switches — delay buffer size, Curve EQ topology, filter modulation curve, async convolution damping, and neural network warmup.
- [Polyphony & Channels](/v2/reference/preprocessors/polyphony-and-channels): Compile-time array sizes for voices, channels, and routing matrices — must match exactly between HISE, project DLLs, and exported plugins.
- [Modulator Slots](/v2/reference/preprocessors/modulator-slots): Parameter modulation slot counts for every scriptnode and hardcoded host module, plus the master cap that limits modulators per chain.
- [Backwards Compatibility](/v2/reference/preprocessors/backwards-compatibility): Flags that re-enable superseded HISE behaviours so shipped products keep sounding identical after a rebuild.
