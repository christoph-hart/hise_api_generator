---
title: Preprocessor Reference
description: Compile-time macros that change HISE behaviour project-wide
---

HISE preprocessors are compile-time macros set in a project's ExtraDefinitions field. They change engine behaviour, array sizes, optional library inclusion and bit-exact audio paths at build time, so every flag must match between the HISE build and any exported plugin. The defaults are sensible for new projects — only reach for these when you are maintaining a shipped product, trimming compile time, or opting into an optional feature.

## Categories

- [Third-Party Modules](/v2/reference/preprocessors/third-party-modules): Optional third-party libraries and SDK integrations — Loris, rLottie, RTNeural, pitch detection, FFTW3, IPP, xsimd, MuseHub, Beatport, NKS.
- [Plugin Type](/v2/reference/preprocessors/plugin-type): Plugin type and host bus configuration — instrument vs effect, audio input routing, mono layout, and FX-build sound generator handling.
- [Sampler & Streaming](/v2/reference/preprocessors/sampler-and-streaming): Streaming sampler backend and sample-installation UX — monolith access, preload threshold, release start, and SamplesNotInstalled overlay buttons.
- [DSP & Filters](/v2/reference/preprocessors/dsp-and-filters): Module-specific DSP switches — delay buffer size, Curve EQ topology, filter modulation curve, async convolution damping, and neural network warmup.
- [Polyphony & Channels](/v2/reference/preprocessors/polyphony-and-channels): Compile-time array sizes for voices, channels, and routing matrices — must match exactly between HISE, project DLLs, and exported plugins.
- [Backwards Compatibility](/v2/reference/preprocessors/backwards-compatibility): Flags that re-enable superseded HISE behaviours so shipped products keep sounding identical after a rebuild.
- [Audio Processing](/v2/reference/preprocessors/audio-processing): Block-level audio engine knobs — modulation raster, processing block size, voice culling, tempo-sync range, and suspended-voice handling.
- [UI & Graphics](/v2/reference/preprocessors/ui-and-graphics): Plugin UI code-path toggles — OpenGL rendering, bundled Lato font, alert look-and-feel, floating tiles, registration overlay, splash screen.
- [Preset & State](/v2/reference/preprocessors/preset-and-state): Exported plugin state handling — AppData location, asset baking, first-launch folders, preset overwrite policy, tempo persistence, undo coalescing.
