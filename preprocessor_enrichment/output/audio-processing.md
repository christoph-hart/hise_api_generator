---
title: Audio Processing
description: Block-level audio engine knobs — modulation raster, processing block size, voice culling, tempo-sync range, and suspended-voice handling.
---

Preprocessors in this category change how the audio engine renders each block. They cover the control-rate modulation raster, the maximum processing block size that downstream DSP code assumes, the silence-detection threshold for voice culling, the tempo value range available to every tempo-synced parameter, and the handling of suspension tails when voices are killed. Most entries are bit-exact switches that affect the sound or the CPU cost of every voice, so changing them ripples through the entire project. Before touching any of these, confirm that the trade-off is worth the reduction in preset compatibility with the default build.

### HISE_USE_EXTENDED_TEMPO_VALUES

Adds longer tempo divisions (up to eight bars) to every tempo-synced parameter in the project.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

The built-in tempo list that feeds every TempoSync slider, the arpeggiator's Tempo parameter and the `Engine.getTempoInMilliSeconds` / `TransportHandler` scripting APIs only goes up to a whole note by default. Enabling this flag prepends five longer values (EightBar, SixBar, FourBar, ThreeBar, TwoBars) to the front of the list, which is useful for slowly evolving ambient patches or long arpeggiator phrases.
> Turning this on shifts every existing tempo index by 5, so any user preset that stored a tempo as an integer index before the change will map to a different note value after recompiling. The flag must be set consistently for both the HISE build and the exported plugin, otherwise stored indices will not round-trip.

**See also:** $MODULES.Arpeggiator$ -- exposes the extended divisions on its Tempo parameter, $API.Engine$ -- tempoIndex arguments on getTempoInMilliSeconds and related methods shift by five, $API.TransportHandler$ -- beat-grid callbacks use the extended tempo enum
