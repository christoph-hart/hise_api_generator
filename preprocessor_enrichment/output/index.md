---
title: Preprocessor Reference
description: Compile-time macros that change HISE behaviour project-wide
---

HISE preprocessors are compile-time macros set in a project's ExtraDefinitions field. They change engine behaviour, array sizes, optional library inclusion and bit-exact audio paths at build time, so every flag must match between the HISE build and any exported plugin. The defaults are sensible for new projects — only reach for these when you are maintaining a shipped product, trimming compile time, or opting into an optional feature.

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
