---
title: Dynamics
moduleId: Dynamics
type: Effect
subtype: MasterEffect
tags: [dynamics, mixing]
builderPath: b.Effects.Dynamics
screenshot: /images/v2/reference/audio-modules/dynamics.png
cpuProfile:
  baseline: low
  polyphonic: false
  scalingFactors:
    - { parameter: "Enabled stages", impact: low, note: "Each enabled stage adds one per-sample processing loop. All three enabled is still low-to-medium." }
seeAlso:
  - { id: SimpleGain, type: alternative, reason: "Simpler gain control without gate, compressor, or limiter stages" }
commonMistakes:
  - wrong: "Enabling a stage but leaving its threshold at 0 dB and expecting an effect"
    right: "Lower the threshold below 0 dB to hear the gate, compressor, or limiter working"
    explanation: "All thresholds default to 0 dB. At 0 dB, the gate never closes, the compressor never engages, and the limiter never limits because the signal is always below the threshold."
  - wrong: "Enabling the compressor with ratio 1:1 and expecting compression"
    right: "Increase the ratio above 1:1 to apply compression"
    explanation: "A ratio of 1:1 means no gain reduction. The default ratio is 1:1, so the compressor does nothing until the ratio is increased."
  - wrong: "Toggling the gate or compressor rapidly and hearing clicks"
    right: "Only the limiter has a crossfade on toggle. Gate and compressor switch instantly."
    explanation: "The limiter uses a one-block crossfade when enabled or disabled to prevent clicks. The gate and compressor do not have this mechanism, so toggling them during playback may produce audible artefacts."
customEquivalent:
  approach: scriptnode
  moduleType: HardcodedFX
  complexity: medium
  description: "A scriptnode network with gate, compressor, and limiter nodes in series can replicate this module's three-stage dynamics chain"
llmRef: |
  Dynamics (MasterEffect)

  A three-stage dynamics processor combining a noise gate, downward compressor, and brick-wall limiter in a fixed serial chain. Each stage can be independently enabled or disabled. Disabled stages consume zero CPU. All processing is per-sample.

  Signal flow:
    audio in -> [Gate] -> [Compressor -> Compressor Makeup] -> [Limiter -> Limiter Makeup] -> audio out

  CPU: low (single stage) to low-medium (all stages). Monophonic.

  Parameters:
    Gate:
      GateEnabled (Off/On, default Off) - enables the noise gate
      GateThreshold (-100 - 0 dB, default 0 dB) - level below which the gate attenuates
      GateAttack (0 - 100 ms, default 1 ms) - gate open time
      GateRelease (0 - 300 ms, default 100 ms) - gate close time
      GateReduction (read-only) - current gain reduction meter
    Compressor:
      CompressorEnabled (Off/On, default Off) - enables the compressor
      CompressorThreshold (-100 - 0 dB, default 0 dB) - compression knee point
      CompressorRatio (1 - 32, default 1:1) - compression ratio
      CompressorAttack (0 - 100 ms, default 10 ms) - compressor response time
      CompressorRelease (0 - 300 ms, default 100 ms) - compressor recovery time
      CompressorReduction (read-only) - current gain reduction meter
      CompressorMakeup (Off/On, default Off) - auto makeup gain
    Limiter:
      LimiterEnabled (Off/On, default Off) - enables the brick-wall limiter
      LimiterThreshold (-100 - 0 dB, default 0 dB) - maximum output level
      LimiterAttack (0 - 100 ms, default 1 ms) - limiter response time
      LimiterRelease (0 - 300 ms, default 10 ms) - limiter recovery time
      LimiterReduction (read-only) - current gain reduction meter
      LimiterMakeup (Off/On, default Off) - auto makeup gain

  When to use:
    Channel strip dynamics on a stereo bus. Enable only the stages you need. Gate for noise removal, compressor for dynamic range control, limiter for peak protection.

  Common mistakes:
    All thresholds default to 0 dB (no effect). Compressor ratio defaults to 1:1 (no compression). Gate/compressor toggle instantly (may click).

  Custom equivalent:
    scriptnode HardcodedFX with gate, compressor, and limiter nodes in series.

  See also:
    alternative SimpleGain - simpler gain control without dynamics stages
---

::category-tags
---
tags:
  - { name: dynamics, desc: "Effects that shape the amplitude or add distortion and saturation" }
  - { name: mixing, desc: "Effects that control volume, stereo width, or stereo balance" }
---
::

![Dynamics screenshot](/images/v2/reference/audio-modules/dynamics.png)

The Dynamics module is a three-stage dynamics processor with a noise gate, downward compressor, and brick-wall limiter arranged in a fixed serial chain. Each stage can be independently enabled or disabled, and disabled stages are fully bypassed with zero CPU cost.

All three stages process per-sample for accurate envelope tracking. The compressor and limiter each offer an auto-makeup toggle that compensates for gain reduction based on the threshold (and ratio for the compressor). The three read-only Reduction parameters provide gain reduction metering for each stage.

## Signal Path

::signal-path
---
glossary:
  parameters:
    GateEnabled:
      desc: "Enables the noise gate stage"
      range: "Off / On"
      default: "Off"
    GateThreshold:
      desc: "Level below which the gate attenuates the signal"
      range: "-100 - 0 dB"
      default: "0 dB"
    GateAttack:
      desc: "Time for the gate to open"
      range: "0 - 100 ms"
      default: "1 ms"
    GateRelease:
      desc: "Time for the gate to close"
      range: "0 - 300 ms"
      default: "100 ms"
    CompressorEnabled:
      desc: "Enables the compressor stage"
      range: "Off / On"
      default: "Off"
    CompressorThreshold:
      desc: "Level above which compression begins"
      range: "-100 - 0 dB"
      default: "0 dB"
    CompressorRatio:
      desc: "Compression ratio (e.g. 4 means 4:1)"
      range: "1 - 32"
      default: "1 (no compression)"
    CompressorAttack:
      desc: "Compressor response time"
      range: "0 - 100 ms"
      default: "10 ms"
    CompressorRelease:
      desc: "Compressor recovery time"
      range: "0 - 300 ms"
      default: "100 ms"
    CompressorMakeup:
      desc: "Enables auto makeup gain after compression"
      range: "Off / On"
      default: "Off"
    LimiterEnabled:
      desc: "Enables the brick-wall limiter stage"
      range: "Off / On"
      default: "Off"
    LimiterThreshold:
      desc: "Maximum output level ceiling"
      range: "-100 - 0 dB"
      default: "0 dB"
    LimiterAttack:
      desc: "Limiter response time"
      range: "0 - 100 ms"
      default: "1 ms"
    LimiterRelease:
      desc: "Limiter recovery time"
      range: "0 - 300 ms"
      default: "10 ms"
    LimiterMakeup:
      desc: "Enables auto makeup gain after limiting"
      range: "Off / On"
      default: "Off"
  functions:
    gate:
      desc: "Per-sample noise gate that attenuates signal below the threshold"
    compress:
      desc: "Per-sample downward compressor that reduces gain above the threshold"
    limit:
      desc: "Per-sample brick-wall limiter that prevents signal from exceeding the threshold"
---

```
// Dynamics - monophonic, three-stage serial chain
// stereo in -> stereo out

// Stage 1: Gate
if GateEnabled:
    signal = gate(signal, GateThreshold, GateAttack, GateRelease)

// Stage 2: Compressor
if CompressorEnabled:
    signal = compress(signal, CompressorThreshold, CompressorRatio,
                      CompressorAttack, CompressorRelease)
    if CompressorMakeup:
        signal *= makeupGain(CompressorThreshold, CompressorRatio)

// Stage 3: Limiter (crossfades on enable/disable)
if LimiterEnabled:
    signal = limit(signal, LimiterThreshold, LimiterAttack, LimiterRelease)
    if LimiterMakeup:
        signal *= makeupGain(LimiterThreshold)

output = signal
```

::

## Parameters

::parameter-table
---
groups:
  - label: Gate
    params:
      - { name: GateEnabled, desc: "Enables the noise gate. When off, this stage is fully bypassed.", range: "Off / On", default: "Off" }
      - { name: GateThreshold, desc: "The level in dB below which the gate attenuates the signal. Lower values allow quieter signals through.", range: "-100 - 0 dB", default: "0 dB" }
      - { name: GateAttack, desc: "Time in milliseconds for the gate to open when the signal exceeds the threshold.", range: "0 - 100 ms", default: "1 ms" }
      - { name: GateRelease, desc: "Time in milliseconds for the gate to close when the signal falls below the threshold.", range: "0 - 300 ms", default: "100 ms" }
      - { name: GateReduction, desc: "Read-only. Displays the current gate gain reduction with peak-hold and exponential decay.", range: "(read-only)", default: "0" }
  - label: Compressor
    params:
      - { name: CompressorEnabled, desc: "Enables the downward compressor. When off, this stage is fully bypassed.", range: "Off / On", default: "Off" }
      - { name: CompressorThreshold, desc: "The level in dB above which compression begins.", range: "-100 - 0 dB", default: "0 dB" }
      - { name: CompressorRatio, desc: "Compression ratio. A value of 4 means 4:1 compression. 1 means no compression.", range: "1 - 32", default: "1" }
      - { name: CompressorAttack, desc: "Time in milliseconds for the compressor to respond to signals above the threshold.", range: "0 - 100 ms", default: "10 ms" }
      - { name: CompressorRelease, desc: "Time in milliseconds for the compressor to return to normal gain.", range: "0 - 300 ms", default: "100 ms" }
      - { name: CompressorReduction, desc: "Read-only. Displays the current compressor gain reduction.", range: "(read-only)", default: "0" }
      - { name: CompressorMakeup, desc: "Enables automatic makeup gain calculated from the threshold and ratio to compensate for compression.", range: "Off / On", default: "Off" }
  - label: Limiter
    params:
      - { name: LimiterEnabled, desc: "Enables the brick-wall limiter. Uses a one-block crossfade when toggled to prevent clicks.", range: "Off / On", default: "Off" }
      - { name: LimiterThreshold, desc: "The ceiling level in dB that the signal cannot exceed.", range: "-100 - 0 dB", default: "0 dB" }
      - { name: LimiterAttack, desc: "Time in milliseconds for the limiter to respond to peaks above the threshold.", range: "0 - 100 ms", default: "1 ms" }
      - { name: LimiterRelease, desc: "Time in milliseconds for the limiter to return to normal gain.", range: "0 - 300 ms", default: "10 ms" }
      - { name: LimiterReduction, desc: "Read-only. Displays the current limiter gain reduction.", range: "(read-only)", default: "0" }
      - { name: LimiterMakeup, desc: "Enables automatic makeup gain calculated from the threshold to compensate for limiting.", range: "Off / On", default: "Off" }
---
::

## Notes

The three stages always process in fixed order: gate, then compressor, then limiter. This order cannot be changed.

All stages default to disabled with thresholds at 0 dB. A newly added Dynamics module passes audio through unchanged until at least one stage is enabled and its threshold lowered.

The compressor makeup gain is calculated as the theoretical gain reduction at the threshold: for a threshold of -20 dB and ratio of 4:1, the makeup gain is approximately 15 dB. The limiter makeup gain is simply the inverse of the threshold: a -6 dB threshold produces +6 dB makeup.

The limiter uses a one-block crossfade when its enabled state changes, preventing clicks. The gate and compressor do not have this crossfade, so toggling them during playback may produce audible artefacts.

The Reduction parameters (GateReduction, CompressorReduction, LimiterReduction) use peak-hold with exponential decay for metering. They cannot be set - they are output-only values for display purposes.

**See also:** $MODULES.SimpleGain$ -- Simpler gain control without gate, compressor, or limiter stages
