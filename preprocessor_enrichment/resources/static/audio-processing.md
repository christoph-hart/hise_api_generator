---
description: Block-level audio engine knobs — modulation raster, processing block size, voice culling, tempo-sync range, and suspended-voice handling.
---

Preprocessors in this category change how the audio engine renders each block. They cover the control-rate modulation raster, the maximum processing block size that downstream DSP code assumes, the silence-detection threshold for voice culling, the tempo value range available to every tempo-synced parameter, and the handling of suspension tails when voices are killed. Most entries are bit-exact switches that affect the sound or the CPU cost of every voice, so changing them ripples through the entire project. Before touching any of these, confirm that the trade-off is worth the reduction in preset compatibility with the default build.
