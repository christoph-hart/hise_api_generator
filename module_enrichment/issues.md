# Module Pipeline Issues

Bugs, design issues, and silent failures discovered during C++ signal flow exploration (Phase 1).
Sorted by severity (critical first).

**Types:** silent-fail, missing-validation, inconsistency, code-smell, ux-issue, vestigial
**Severity:** critical, high, medium, low

---

## Critical

(No issues yet.)

## High

(No issues yet.)

## Medium

### Delay -- tempoChanged() assigns syncTimeLeft to both channels

- **Type:** inconsistency
- **Severity:** medium
- **Location:** hi_core/hi_modules/effects/fx/Delay.h:76
- **Observed:** In `tempoChanged()`, line 76 computes `delayTimeRight = TempoSyncer::getTempoInMilliSeconds(newTempo, syncTimeLeft)` using `syncTimeLeft` instead of `syncTimeRight`. This writes an incorrect value to `delayTimeRight`. However, `calcDelayTimes()` is called immediately after on line 78, which recalculates the actual delay times from the correct `syncTimeLeft`/`syncTimeRight` values and calls `setDelayTimeSeconds()` on both delay lines. The cached `delayTimeRight` member is only read back by `getAttribute(DelayTimeRight)` in the non-tempo-synced branch, so the wrong value may never surface in practice (the variable is only meaningful when `tempoSync == false`, but `tempoChanged` only runs when `tempoSync == true`).
- **Expected:** Line 76 should use `syncTimeRight` instead of `syncTimeLeft`: `delayTimeRight = TempoSyncer::getTempoInMilliSeconds(newTempo, syncTimeRight);`

### Delay -- LowPassFreq and HiPassFreq parameters are vestigial

- **Type:** vestigial
- **Severity:** medium
- **Location:** hi_core/hi_modules/effects/fx/Delay.h:56-57, Delay.cpp:71-80
- **Observed:** `LowPassFreq` and `HiPassFreq` are defined in the `Parameters` enum (indices 4 and 5), stored as member variables, serialized in `restoreFromValueTree`/`exportAsValueTree`, exposed in `getAttribute`/`setInternalAttribute`, and registered in `createMetadata()` with descriptions claiming they are "applied to the delay feedback". However, no filter objects exist in the class and `applyEffect()` does not reference these values anywhere. The delay editor also does not expose sliders for them. The parameters are fully wired for persistence and metadata but have zero DSP effect.
- **Expected:** Either implement the filters (add filter objects and apply them in the feedback path as the metadata descriptions claim) or remove the parameters from the enum and metadata to avoid confusion.

### AHDSR -- EcoMode parameter is vestigial

- **Type:** vestigial
- **Severity:** medium
- **Location:** hi_core/hi_modules/modulators/mods/AhdsrEnvelope.cpp:441
- **Observed:** The `EcoMode` parameter (index 10) is defined in the enum, serialized, exposed in metadata with description "Enables 16x downsampling for reduced CPU usage", and defaults to 1.0 (enabled). However, `setInternalAttribute` handles it with `case EcoMode: break; // not needed anymore...` and `getAttribute` returns a hardcoded `1.0f`. The actual control rate downsampling is now handled globally by `HISE_CONTROL_RATE_DOWNSAMPLING_FACTOR` (8x for instruments, 1x for effects), making EcoMode redundant.
- **Expected:** Either remove the parameter from the enum and metadata, or document in the metadata description that it has no effect and downsampling is controlled globally.

### GlobalTimeVariantModulator -- Inverted parameter has no effect when UseTable is enabled

- **Type:** silent-fail
- **Severity:** medium
- **Location:** hi_core/hi_modules/modulators/mods/GlobalModulators.cpp (calculateBlock table path)
- **Observed:** In `calculateBlock()`, when `useTable` is true, the while loop uses `--numSamples` as both the loop condition and the per-sample counter, decrementing it to 0 or -1. After the loop, `invertBuffer(internalBuffer, numSamples)` is called, but `numSamples` is now <= 0, so the guard condition in `invertBuffer()` prevents execution. Inversion never applies in the table path. The non-table path works correctly because `numSamples` is not consumed before `invertBuffer()` is called.
- **Expected:** Save `numSamples` to a local variable before the table loop, then pass the original count to `invertBuffer()`. Alternatively, restructure the loop to not consume `numSamples`.

### GlobalEnvelopeModulator -- Inverted parameter is vestigial (inversion code commented out)

- **Type:** vestigial
- **Severity:** medium
- **Location:** hi_core/hi_modules/modulators/mods/GlobalModulators.cpp (calculateBlock)
- **Observed:** The `Inverted` parameter is defined in the enum, exposed in the editor UI, and serialized, but the inversion code in `calculateBlock()` is commented out in both the table and non-table paths. The parameter has no effect on the modulation output despite being visible to users.
- **Expected:** Either uncomment and verify the inversion code, or remove the Inverted parameter from the enum and editor to avoid user confusion.

### SimpleReverb -- DryLevel parameter is vestigial (slaved to WetLevel)

- **Type:** vestigial
- **Severity:** medium
- **Location:** hi_core/hi_modules/effects/fx/SimpleReverb.h:99-101
- **Observed:** In `setInternalAttribute()`, setting WetLevel (case WetLevel) also sets `parameters.dryLevel = 1.0f - newValue`. Setting DryLevel (case DryLevel) contains only `break;` - it does nothing. The DryLevel slider appears in the UI and its value is serialized, but changing it has no effect on the audio output. WetLevel fully controls both wet and dry levels.
- **Expected:** Either make DryLevel independently functional (remove the automatic `dryLevel = 1 - wetLevel` coupling), or remove the DryLevel parameter from the enum and metadata and rename WetLevel to "Mix" to clarify that it controls the wet/dry balance.

### ShapeFX -- Drive parameter is vestigial (not read in applyEffect)

- **Type:** vestigial
- **Severity:** medium
- **Location:** hi_core/hi_modules/effects/fx/ShapeFX.cpp:212, ShapeFX.cpp:574-665
- **Observed:** The `Drive` parameter (index 10) is defined in the enum, stored as a member variable (`drive`), serialised in `exportAsValueTree`/`restoreFromValueTree`, and exposed in `createMetadata()` with description "Drive amount applied to the shaper input". However, in `setInternalAttribute()` the handler is `case Drive: drive = newValue; break;` with no call to `updateMode()` or `updateGain()`, and the `drive` member is never read in `applyEffect()`. The only input gain applied is via `gainer.processBlock()` which uses the `gain` member (set from the Gain parameter). Drive IS functional in the polyphonic variant PolyshapeFX where it multiplies the audio signal per-sample.
- **Expected:** Either connect Drive to the DSP path (multiply into the signal before shaping, similar to PolyshapeFX), or remove it from the metadata to avoid user confusion. The parameter currently appears in the UI but does nothing.

## Low

### Convolution -- ImpulseLength parameter is vestigial

- **Type:** vestigial
- **Severity:** medium
- **Location:** hi_core/hi_modules/effects/fx/Convolution.cpp:122, 147-148
- **Observed:** The `ImpulseLength` parameter (index 3) is defined in the enum, serialised in `restoreFromValueTree`/`exportAsValueTree`, and registered in `createMetadata()` with description "Deprecated impulse length control". In `getAttribute()`, it returns a hardcoded `1.0f`. In `setInternalAttribute()`, it calls `setImpulse(sendNotificationAsync)` but stores no value - the reload uses the full buffer range from the AudioSampleProcessor. The parameter is fully vestigial. The metadata description correctly notes it as deprecated.
- **Expected:** Remove the parameter from the enum and metadata, or keep it for serialisation backwards compatibility with a clearer note that it is a no-op.

### Convolution -- Latency parameter stored but never consumed

- **Type:** vestigial
- **Severity:** medium
- **Location:** hi_core/hi_modules/effects/fx/Convolution.cpp:143-145; hi_dsp_library/dsp_basics/ConvolutionBase.cpp:610-621
- **Observed:** The `Latency` parameter (index 2) is stored as `latency = (int)newValue` and triggers `setImpulse(sendNotificationAsync)`. However, `reloadInternal()` derives the head block size from `lastBlockSize` (the audio buffer size), not from the `latency` member. The `latency` member is never read in the signal path or IR reload. Additionally: (1) the metadata range is 0.0-1.0 (uninitialised default), inconsistent with the description "in samples, which must be a power of two"; (2) `jassert(isPowerOfTwo(latency))` fires on the default value of 0 in debug builds since `isPowerOfTwo(0)` returns false. The description claims it controls convolution latency but the parameter has no effect on processing.
- **Expected:** Either wire the `latency` member into `reloadInternal()` as the head block size (replacing `lastBlockSize`), with a proper range and default, or remove the parameter if the automatic block-size-based head sizing is the intended behaviour.

### WaveSynth -- voicePitchValues incremented unconditionally when potentially null

- **Type:** code-smell
- **Severity:** low
- **Location:** hi_core/hi_modules/synthesisers/synths/WaveSynth.cpp:597
- **Observed:** In `calculateBlock()`, the single-oscillator pitch-modulated path (line 585-602) is entered when the outer condition `(voicePitchValues == nullptr && secondPitchValues == nullptr)` is false. Inside this block, line 591 checks `if (voicePitchValues != nullptr)` before dereferencing, but line 597 increments `voicePitchValues++` unconditionally. If `voicePitchValues` is null (possible when only `secondPitchValues` is non-null), this increments a null pointer. In practice this is unreachable because `enableSecondOsc` is false in this branch and having a populated Osc2PitchChain with osc2 disabled is not a realistic configuration.
- **Expected:** Guard the increment with `if (voicePitchValues != nullptr)` to match the dual-oscillator path (line 579-580), or restructure the outer condition to check `voicePitchValues` independently.
