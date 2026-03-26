# Module Pipeline Issues

Bugs, design issues, and silent failures discovered during C++ signal flow exploration (Phase 1).
Sorted by severity (critical first).

**Types:** silent-fail, missing-validation, inconsistency, code-smell, ux-issue, vestigial
**Severity:** critical, high, medium, low

---

## Critical

(No issues yet.)

## High

### CC2Note -- Bypass parameter description is misleading

- **Type:** inconsistency
- **Severity:** high
- **Location:** hi_scripting/scripting/HardcodedScriptProcessor.h:538-559
- **Observed:** The Bypass parameter metadata description says "Bypasses CC-to-note triggering", but the `Synth.playNote()` call at line 559 is outside the bypass guard (lines 538-555). Bypass only toggles between custom round-robin group cycling (bypass OFF) and the Sampler's built-in round-robin (bypass ON, via `Sampler.enableRoundRobin(true)` in `onControl()` at line 570). Notes are always generated from CC regardless of bypass state.
- **Expected:** Either: (a) move the `Synth.playNote()` call inside the bypass guard so that bypass actually stops note generation, or (b) update the metadata description to "Switches between custom paired group cycling and the Sampler's built-in round-robin" to accurately reflect the behavior.

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

### HarmonicFilter -- Non-SSE filter path collapses stereo to mono

- **Type:** inconsistency
- **Severity:** medium
- **Location:** hi_core/hi_modules/effects/fx/HarmonicFilter.h:119
- **Observed:** In `PeakFilterBand::State::process(FloatType& left, FloatType& right)` (the non-SSE path), line 119 sets `right = left` after processing, meaning the right channel always receives a copy of the left channel's filtered output. The SSE path (`process(SSEType& input)`) processes both channels independently via SIMD. On non-SSE builds, the HarmonicFilter produces mono output even when given stereo input. The `processSamples()` method passes separate left and right pointers, but the scalar `process()` ignores the right channel's input and overwrites it.
- **Expected:** The non-SSE path should process each channel independently (duplicate the SVF state for L/R or process them in separate calls), matching the SSE path's behavior.

### PolyshapeFX -- Mode parameter range includes unregistered modes that silently fall back to Linear

- **Type:** inconsistency
- **Severity:** medium
- **Location:** hi_core/hi_modules/effects/fx/WaveShapers.cpp:422-440
- **Observed:** The Mode parameter range is 0-33 (matching the ShapeFX::ShapeMode enum), but `PolyshapeFX::initShapers()` only registers 10 of the 34 slots. Modes 3 (Tanh), 6 (Saturate), 7 (Square), and 8 (SquareRoot) are valid enum values registered in ShapeFX but not in PolyshapeFX. Selecting these modes gives Linear passthrough with no warning. The shapers array is pre-filled with Linear instances for all slots, so any unregistered mode index silently degrades to passthrough. The metadata `Mode` parameter description says "populated dynamically from available shapers" but the range includes unavailable shapers.
- **Expected:** Either register the missing modes (Tanh, Saturate, Square, SquareRoot) in `PolyshapeFX::initShapers()`, or restrict the Mode parameter range/items to only the 10 actually registered modes so the UI does not present non-functional options.

### PolyphonicFilter -- StateVariablePeak and LadderFourPoleHP modes not wired in setMode()

- **Type:** silent-fail
- **Severity:** medium
- **Location:** hi_core/hi_modules/effects/fx/FilterHelpers.cpp:54-117
- **Observed:** `FilterBank::setMode()` has no `case` for `FilterMode::StateVariablePeak` (index 11) or `FilterMode::LadderFourPoleHP` (index 16). Both fall through to `default: break;`, which means selecting either mode does not change the internal filter topology - the previously active filter type continues processing. The modes are defined in the `FilterMode` enum (FilterHelpers.h:49-69), have display coefficient entries in `getDisplayCoefficients()` (FilterHelpers.cpp:318,320), and are exposed in the scripting API via `FilterModeObject`. The frequency response graph updates (because `getDisplayCoefficients` handles them), but the actual audio processing uses the wrong filter.
- **Expected:** Add cases to `setMode()`: `StateVariablePeak` should map to `StateVariableFilterSubType` (needs a PEAK sub-type addition or map to `StateVariableEqSubType` which has a Peak mode), and `LadderFourPoleHP` should map to `LadderSubType` (needs an HP sub-type addition, as `LadderSubType` currently only defines `LP24`).

### PolyphonicFilter -- Quality parameter is vestigial (not consumed in render path)

- **Type:** vestigial
- **Severity:** medium
- **Location:** hi_core/hi_modules/effects/fx/Filters.cpp:246, hi_core/hi_modules/effects/fx/FilterHelpers.h:495
- **Observed:** The `Quality` parameter is stored via `setRenderQuality()` into `FilterEffect::quality` and retrievable via `getSampleAmountForRenderQuality()`. However, neither `renderNextBlock()` nor `applyEffect()` reads this value. The mono path uses `BlockDivider<64>` (compile-time constant of 64 samples) for sub-block processing, and the poly path processes the entire voice buffer as one block. The `quality` member is never referenced in the signal path. The metadata description ("Internal render quality as power-of-two buffer size for modulation processing") suggests it should control the coefficient update interval, but it does not.
- **Expected:** Either connect `quality` to the sub-block size in `renderNextBlock()` (replacing the hardcoded `BlockDivider<64>`), or remove/deprecate the parameter in metadata.

### LegatoWithRetrigger -- onNoteOff Block 3 missing channel check

- **Type:** inconsistency
- **Severity:** medium
- **Location:** hi_scripting/scripting/HardcodedScriptProcessor.h:242
- **Observed:** In `onNoteOff()`, Block 1 (line 226) checks both note number and channel (`Message.getNoteNumber() == lastNote && Message.getChannel() == lastChannel`) to identify the currently sounding note. However, Block 3 (line 242) only checks note number (`number == lastNote`) without a channel check. In multi-channel scenarios (e.g., MPE), a noteOff for the correct note number on a different channel would skip Block 1 (no event suppression or artificial noteOff) but enter Block 3 (triggering retrigger or clearing `lastNote`). This causes state desync: the active note's artificial event is not killed, but `lastNote` is either overwritten by a retrigger or set to -1.
- **Expected:** Block 3's condition should also check channel: `if(number == lastNote && channel == lastChannel)` to match Block 1's behavior.

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

### NoiseGrainPlayer -- setIncludeMonophonicValuesInVoiceRendering called twice on same chain

- **Type:** code-smell
- **Severity:** low
- **Location:** hi_core/hi_modules/effects/fx/NoiseGrainPlayer.cpp:157-158
- **Observed:** The constructor calls `modChains[InternalChains::PositionBipolar].setIncludeMonophonicValuesInVoiceRendering(true)` twice (lines 157 and 158). The second call appears to be a copy-paste error - line 158 should likely target `PositionChain` (index 0) instead of `PositionBipolar` (index 1) again. As a result, `PositionChain` never has monophonic values included in voice rendering, which may affect modulation behavior when monophonic modulators are added to the gain chain.
- **Expected:** Line 158 should be `modChains[InternalChains::PositionChain].setIncludeMonophonicValuesInVoiceRendering(true);`

### NoiseGrainPlayer -- EditorStates enum has duplicate values

- **Type:** code-smell
- **Severity:** low
- **Location:** hi_core/hi_modules/effects/fx/NoiseGrainPlayer.h:68-69
- **Observed:** `PositionChainShown` and `PositionBipolarShown` are both set to `Processor::numEditorStates`. The second entry should increment from the first. This means both editor states map to the same bit, so toggling one toggles the other.
- **Expected:** `PositionBipolarShown` should be `Processor::numEditorStates + 1` (or simply follow `PositionChainShown` without explicit assignment).

### NoiseGrainPlayer -- Header class comment is copy-pasted from StereoEffect

- **Type:** ux-issue
- **Severity:** low
- **Location:** hi_core/hi_modules/effects/fx/NoiseGrainPlayer.h:37
- **Observed:** The Doxygen class comment reads "A simple stereo panner which can be modulated using all types of Modulators" which describes StereoEffect, not NoiseGrainPlayer. The `JUCE_DECLARE_WEAK_REFERENCEABLE(StereoEffect)` macro at line 233 also references StereoEffect instead of NoiseGrainPlayer, confirming the class was scaffolded from StereoEffect.
- **Expected:** Update the class comment to describe the granular noise player, and fix the weak-referenceable macro to use `NoiseGrainPlayer`.

### Transposer -- Metadata description misleadingly says "note-on events" only

- **Type:** inconsistency
- **Severity:** low
- **Location:** hi_core/hi_modules/midi_processor/mps/Transposer.cpp:42, 45
- **Observed:** Both the module description ("Transposes incoming MIDI note-on events by a fixed number of semitones") and the TransposeAmount parameter description ("Semitone offset applied to incoming note-on events") say "note-on events". While technically accurate at the processor level (only `processHiseEvent` touches note-ons), the EventIdHandler automatically propagates the transpose amount to matching note-off events (HiseEventBuffer.cpp:1003,1019). From a user perspective, both note-on and note-off are transposed. The current wording could mislead users into thinking note-offs are not handled.
- **Expected:** Change "note-on events" to "MIDI notes" in both the module description and the parameter description to reflect the effective end-to-end behavior.

### ChannelFilter -- MPE mode initial state does not allow channel 1

- **Type:** inconsistency
- **Severity:** low
- **Location:** hi_scripting/scripting/HardcodedScriptProcessor.h:642-644
- **Observed:** In `onInit()`, the `mpeRange` bitmask is set to `mpeRange.setRange(1, 15, true)` which enables bits 1-15 (channels 2-16) but does not set bit 0 (channel 1, the MPE master channel). The `onControl()` handler (line 723) always force-enables bit 0 with `mpeRange.setBit(0, true)` after any MPE parameter change. This means on initial load (before the user changes any MPE parameter), if MPE mode is enabled globally, channel 1 events would be filtered out. After any MPE parameter change, channel 1 is correctly allowed. The MPE spec designates channel 1 as the manager channel which should always pass through.
- **Expected:** Add `mpeRange.setBit(0, true)` after line 644 in `onInit()` to match the behavior in `onControl()`, ensuring channel 1 is allowed from initial load.

### ReleaseTrigger -- Time parameter uses HiSlider::Time mode but operates in seconds

- **Type:** inconsistency
- **Severity:** low
- **Location:** hi_scripting/scripting/HardcodedScriptProcessor.cpp:78
- **Observed:** The Time parameter metadata uses `HiSlider::Time` mode which displays with "ms" suffix (per MacroControlledComponents.h:751). However, the parameter range is 0-20 with step 0.1, and the code in `onNoteOff()` (HardcodedScriptProcessor.h:407-410) divides the elapsed time from `Engine.getUptime()` (which returns seconds) directly by `timeKnob->getValue()`. The parameter value is treated as seconds in the signal path, but displayed as milliseconds in the UI. A Time value of 5 would display as "5 ms" but actually represent a 5-second attenuation window.
- **Expected:** Either change the slider mode from `HiSlider::Time` to `HiSlider::Linear` with a custom suffix "s", or multiply the parameter value by 0.001 in the code to convert from the displayed milliseconds to seconds. The former is simpler and matches actual usage.
