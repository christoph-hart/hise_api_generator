---
title: Parametriq EQ
moduleId: CurveEq
type: Effect
subtype: MasterEffect
tags: [filter, mixing]
builderPath: b.Effects.CurveEq
screenshot: /images/v2/reference/audio-modules/curveeq.png
cpuProfile:
  baseline: medium
  polyphonic: false
  scalingFactors:
    - { parameter: "Band count", impact: "linear", note: "Each additional band adds one stereo biquad filter to the cascade" }
seeAlso:
  - { id: PolyphonicFilter, type: alternative, reason: "Single filter with modulation chain support - better suited when per-voice filtering or modulated cutoff is needed" }
  - { id: HarmonicFilter, type: alternative, reason: "Harmonic series filter bank with fixed harmonic spacing - a different approach to spectral shaping" }
commonMistakes:
  - wrong: "Setting the Gain parameter on a Low Pass or High Pass band and expecting it to change the sound"
    right: "Use Gain only with Low Shelf, High Shelf, and Peak band types"
    explanation: "Low Pass and High Pass filters have no gain parameter in their transfer function. The Gain value is stored but has no effect on these filter types."
  - wrong: "Adding many bands without considering CPU cost"
    right: "Keep band count reasonable for the target platform"
    explanation: "Each band adds a stereo biquad filter processed per sample. CPU cost scales linearly with band count. 3-8 bands is typical; 20+ bands may be expensive on constrained platforms."
customEquivalent:
  approach: scriptnode
  moduleType: HardcodedFX
  complexity: medium
  description: "A chain of scriptnode biquad filter nodes can replicate arbitrary EQ curves with the added benefit of per-node modulation"
llmRef: |
  Parametriq EQ (Effect/MasterEffect)

  A parametric equaliser with an unlimited number of dynamically managed filter bands and an optional FFT spectrum display. Bands are processed in series (cascaded) through the stereo signal. Each band has independent frequency, gain, Q, type, and enable controls.

  Signal flow:
    stereo in -> [64-sample sub-blocks] -> band 1 filter -> band 2 filter -> ... -> band N filter -> (optional FFT write) -> stereo out

  CPU: medium baseline (scales linearly with band count), monophonic.
    Band count is the primary scaling factor.

  Per-band parameters:
    Gain (-18 to +18 dB, default 0 dB) - boost/cut amount. Only affects Low Shelf, High Shelf, and Peak types. No effect on Low Pass / High Pass.
    Freq (20 - 20000 Hz, default 1500 Hz) - centre frequency with skewed distribution.
    Q (0.3 - 8.0, default 1.0) - bandwidth / resonance.
    Type (Low Pass, High Pass, Low Shelf, High Shelf, Peak; default Peak) - filter algorithm.
    Enabled (On/Off, default On) - bypasses the individual band.

  Band management:
    Bands are dynamic - added/removed at runtime via the editor UI or scripting API.
    Scripting uses setAttribute with flat indexing: bandIndex * BandOffset + parameterConstant.
    Constants: Gain (0), Freq (1), Q (2), Enabled (3), Type (4), BandOffset (5).

  Spectrum display:
    Optional FFT analyser shows the post-filter spectrum. Disabled by default. Rendered by the DraggableFilterPanel FloatingTile.

  When to use:
    Precise frequency shaping with visual feedback. Suitable for master EQ, mix bus correction, or any scenario requiring multiple independent filter bands. For per-voice filtering or modulated cutoff, use PolyphonicFilter instead.

  Common mistakes:
    Setting Gain on Low Pass / High Pass bands has no effect.
    CPU scales linearly with band count - keep it reasonable.

  Custom equivalent:
    scriptnode HardcodedFX: chain of biquad filter nodes with per-node modulation.

  See also:
    alternative PolyphonicFilter - single filter with modulation chains, per-voice capable
    alternative HarmonicFilter - harmonic series filter bank
---

::category-tags
---
tags:
  - { name: filter, desc: "Modules that shape the frequency spectrum of the signal" }
  - { name: mixing, desc: "Effects that control volume, stereo width, or stereo balance" }
---
::

![Parametriq EQ screenshot](/images/v2/reference/audio-modules/curveeq.png)

The Parametriq EQ is a fully parametric equaliser with a dynamic number of filter bands and an optional FFT spectrum display. Unlike most HISE modules, it has no fixed parameters - bands are added and removed at runtime, each with independent control over frequency, gain, Q factor, filter type, and enable state.

All bands are processed in series: each band's output feeds the next, forming a cascaded filter chain. The order of bands matters, though in practice the audible difference from reordering is negligible for most EQ configurations. An optional spectrum analyser overlays the post-filter frequency content behind the filter curve display, providing real-time visual feedback.

## Signal Path

::signal-path
---
glossary:
  parameters:
    Gain:
      desc: "Per-band boost/cut in decibels. Only affects shelving and peak types."
      range: "-18 - +18 dB"
      default: "0 dB"
    Freq:
      desc: "Per-band centre frequency"
      range: "20 - 20000 Hz"
      default: "1500 Hz"
    Q:
      desc: "Per-band bandwidth / resonance"
      range: "0.3 - 8.0"
      default: "1.0"
    Type:
      desc: "Per-band filter algorithm"
      range: "Low Pass, High Pass, Low Shelf, High Shelf, Peak"
      default: "Peak"
    Enabled:
      desc: "Per-band bypass toggle"
      range: "On / Off"
      default: "On"
  functions:
    applyBiquad:
      desc: "Applies a stereo biquad filter with 280ms parameter smoothing, recalculating coefficients every 64 samples"
    writeFFT:
      desc: "Writes the post-filter output to the FFT ring buffer for spectrum display"
---

```
// Parametriq EQ - monophonic, series cascade
// stereo in -> stereo out (in-place)

process(left, right) {
    // Process in 64-sample sub-blocks for smooth coefficient updates
    for each 64-sample chunk {

        for each band {
            if Enabled:
                applyBiquad(chunk, Freq, Gain, Q, Type)
                // 280ms smoothing on frequency, gain, and Q changes
        }
    }

    // Optional spectrum analyser (post-filter)
    if fftEnabled:
        writeFFT(output)
}
```

::

## Parameters

::parameter-table
---
groups:
  - label: Per-Band Controls
    params:
      - { name: Gain, desc: "Boost or cut in decibels. Only applies to Low Shelf, High Shelf, and Peak filter types. Has no effect on Low Pass or High Pass bands.", range: "-18 - +18 dB", default: "0 dB" }
      - { name: Freq, desc: "Centre frequency of the filter band. Uses a skewed distribution centred at 1500 Hz for more natural control feel.", range: "20 - 20000 Hz", default: "1500 Hz" }
      - { name: Q, desc: "Bandwidth of the filter. Lower values produce a wider curve; higher values produce a narrower, more resonant peak.", range: "0.3 - 8.0", default: "1.0" }
      - { name: Type, desc: "The filter algorithm for this band.", range: "Low Pass, High Pass, Low Shelf, High Shelf, Peak", default: "Peak" }
      - { name: Enabled, desc: "Toggles the band on or off. Disabled bands are skipped during processing at zero cost.", range: "On / Off", default: "On" }
---
::

## Notes

Bands are managed dynamically. In the editor, double-click the filter curve display to add a band, or right-click an existing band to remove it. From HISEScript, use the `setDraggableFilterData()` and `getDraggableFilterData()` methods on the effect reference, or address individual band parameters with flat indexing:

```
// Example: set band 0's frequency to 2000 Hz
eq.setAttribute(0 * eq.BandOffset + eq.Freq, 2000.0);

// Example: set band 2's type to High Shelf (3)
eq.setAttribute(2 * eq.BandOffset + eq.Type, 3);
```

The available scripting constants are: `Gain` (0), `Freq` (1), `Q` (2), `Enabled` (3), `Type` (4), and `BandOffset` (5).

Each band uses biquad filters by default with 280ms parameter smoothing. Coefficients are updated every 64 samples, so rapid automation produces smooth transitions without audible stepping. There are no modulation chains - all parameter changes are applied directly.

The spectrum analyser is disabled by default to save CPU. It shows the post-filter output spectrum overlaid behind the filter curve. The analyser can be toggled from the editor toolbar.

The module is automatically suspended when the input signal is silent.

**See also:** $MODULES.PolyphonicFilter$ -- Single filter with modulation chain support - better suited when per-voice filtering or modulated cutoff is needed, $MODULES.HarmonicFilter$ -- Harmonic series filter bank with fixed harmonic spacing - a different approach to spectral shaping
