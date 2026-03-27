---
title: Analyser
moduleId: Analyser
type: Effect
subtype: MasterEffect
tags: [utility]
builderPath: b.Effects.Analyser
screenshot: /images/v2/reference/audio-modules/analyser.png
cpuProfile:
  baseline: negligible
  polyphonic: false
  scalingFactors: []
seeAlso:
  - { id: AudioAnalyser, type: ui_component, reason: "FloatingTile that displays the Analyser's goniometer, oscilloscope, or spectrum visualisation" }
commonMistakes: []
llmRef: |
  Analyser (MasterEffect)

  A visualisation utility that captures audio data for display without modifying the signal. Provides goniometer (stereo phase), oscilloscope (waveform), and spectrum analyser (frequency content) views via the AudioAnalyser FloatingTile.

  Signal flow:
    audio in -> [copy to display buffer] -> audio out (passthrough, unchanged)

  CPU: negligible, monophonic.

  Parameters:
    PreviewType (Nothing, Goniometer, Oscilloscope, Spectral Analyser, default Nothing) - selects the visualisation mode
    BufferSize (0-32768 samples, default 8192) - ring buffer size, affects frequency resolution and display latency

  When to use:
    Monitoring stereo phase, waveform shape, or frequency content at any point in the effect chain. Insert wherever you need visual feedback.

  See also:
    ui_component AudioAnalyser - FloatingTile displaying the visualisation
---

::category-tags
---
tags:
  - { name: utility, desc: "Modules for analysis, placeholders, or structural purposes without audio processing" }
---
::

![Analyser screenshot](/images/v2/reference/audio-modules/analyser.png)

The Analyser captures audio data for real-time visualisation without modifying the signal. It supports three display modes - goniometer for stereo phase correlation, oscilloscope for waveform monitoring, and spectrum analyser for frequency content - all rendered through the AudioAnalyser FloatingTile.

Audio passes through completely unchanged. The module only copies data into an internal ring buffer when a display component is connected and active, so it adds negligible CPU overhead.

## Parameters

::parameter-table
---
groups:
  - label: Visualisation
    params:
      - { name: PreviewType, desc: "Selects the visualisation mode. Each mode configures the display buffer for a different analysis type.", range: "Nothing, Goniometer, Oscilloscope, Spectral Analyser", default: "Nothing" }
      - { name: BufferSize, desc: "Size of the analysis ring buffer in samples. Larger values give better frequency resolution for the spectrum analyser but increase display latency.", range: "0 - 32768", default: "8192" }
---
::

## Notes

The ring buffer write only occurs when a UI component (the AudioAnalyser FloatingTile) is connected and actively consuming the data. Without a connected display, the module has zero processing overhead beyond the standard effect chain traversal.

Setting PreviewType to Nothing does not explicitly disable the buffer write - the ring buffer may still be written to if a UI component is connected. To minimise overhead when visualisation is not needed, disconnect or hide the display component.

The BufferSize parameter can be changed at runtime. For the spectrum analyser, larger buffers provide finer frequency resolution at the cost of higher display latency. For the oscilloscope and goniometer, the default of 8192 samples is typically sufficient.

**See also:** [AudioAnalyser](/v2/reference/floating-tiles/audioanalyser) -- FloatingTile that renders the goniometer, oscilloscope, or spectrum analyser visualisation from this module's display buffer
