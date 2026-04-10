---
title: Peak
description: "Measures the peak input magnitude and sends it as a normalised modulation signal."
factoryPath: core.peak
factory: core
polyphonic: false
tags: [core, peak, analysis, modulation, envelope-follower]
cpuProfile:
  baseline: negligible
  polyphonic: false
  scalingFactors: []
seeAlso:
  - { id: "core.peak_unscaled", type: disambiguation, reason: "Sends the raw signed peak value without folding to absolute" }
  - { id: "math.sig2mod", type: companion, reason: "Converts a bipolar audio signal to the 0-1 modulation range" }
commonMistakes:
  - title: "Update rate depends on block size"
    wrong: "Expecting sample-accurate modulation output from core.peak"
    right: "Place core.peak inside a container.frame2_block for sample-accurate updates, or container.fix8_block for a fixed update rate."
    explanation: "The node sends one modulation value per audio block. The update rate depends on the surrounding container's block size."
llmRef: |
  core.peak

  Measures the maximum absolute input magnitude across all channels per block and sends it as a normalised (0-1) modulation signal. The audio passes through unmodified.

  Signal flow:
    audio in -> peak detection (abs max across channels) -> modulation out (0..1)
    audio in -> audio out (passthrough)

  CPU: negligible, monophonic

  Parameters:
    None

  When to use:
    Heavily used (rank 12, 28 instances). Use for envelope followers, level-dependent modulation, VU metering, or any scenario where you need to convert audio level into a control signal. Pair with container.fix8_block for a fixed modulation update rate.

  Common mistakes:
    Update rate depends on block size -- use a fixed-block container for predictable timing.

  See also:
    [disambiguation] core.peak_unscaled -- raw signed peak without absolute folding
    [companion] math.sig2mod -- bipolar-to-unipolar signal conversion
---

This node analyses the input signal and detects the maximum absolute value across all channels for each audio block. The result is sent as a normalised modulation signal to any connected target. The audio signal passes through completely unmodified.

The peak value is computed by finding the minimum and maximum sample values in the block, taking the absolute value of each, and returning the larger of the two. For standard audio signals in the -1 to 1 range, the output naturally falls within 0 to 1. If the input exceeds this range, the modulation output will also exceed 1.0.

This node also supports a display buffer that can be visualised on the UI using the [DisplayBuffer]($API.DisplayBuffer$) scripting API. The ring buffer length is configurable between 512 and 65536 samples.

## Signal Path

::signal-path
---
glossary:
  functions:
    peakDetect:
      desc: "Finds the maximum absolute sample value across all channels in the current block"
---

```
// core.peak - peak magnitude to modulation signal
// audio in -> modulation out (0..1)

analyse(input) {
    peak = peakDetect(input)    // max abs value across all channels
    output = peak               // sent as normalised modulation
    // audio passes through unchanged
}
```

::

## Notes

The modulation output updates once per audio block. To get a fixed update rate, wrap this node in a [container.fix8_block]($SN.container.fix8_block$) or similar fixed-block container. For sample-accurate control signals, use [container.frame2_block]($SN.container.frame2_block$).

If you need the raw signed peak value (preserving the sign of the loudest sample), use [core.peak_unscaled]($SN.core.peak_unscaled$) instead.

**See also:** $SN.core.peak_unscaled$ -- raw signed peak without absolute folding, $SN.math.sig2mod$ -- converts bipolar audio to 0-1 modulation range
