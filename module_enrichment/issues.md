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

## Low

### WaveSynth -- voicePitchValues incremented unconditionally when potentially null

- **Type:** code-smell
- **Severity:** low
- **Location:** hi_core/hi_modules/synthesisers/synths/WaveSynth.cpp:597
- **Observed:** In `calculateBlock()`, the single-oscillator pitch-modulated path (line 585-602) is entered when the outer condition `(voicePitchValues == nullptr && secondPitchValues == nullptr)` is false. Inside this block, line 591 checks `if (voicePitchValues != nullptr)` before dereferencing, but line 597 increments `voicePitchValues++` unconditionally. If `voicePitchValues` is null (possible when only `secondPitchValues` is non-null), this increments a null pointer. In practice this is unreachable because `enableSecondOsc` is false in this branch and having a populated Osc2PitchChain with osc2 disabled is not a realistic configuration.
- **Expected:** Guard the increment with `if (voicePitchValues != nullptr)` to match the dual-oscillator path (line 579-580), or restructure the outer condition to check `voicePitchValues` independently.
