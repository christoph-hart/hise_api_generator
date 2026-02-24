# Pipeline Issues

Bugs, design issues, and silent failures discovered during C++ source analysis.
Sorted by severity (critical first).

**Types:** silent-fail, missing-validation, inconsistency, code-smell, ux-issue
**Severity:** critical, high, medium, low

---

## Critical

(No issues yet.)

## High

### GlobalCable.registerCallback -- silent failure for non-RT-safe sync callbacks

- **Type:** silent-fail
- **Severity:** high
- **Location:** ScriptGlobalCable.cpp (WeakCallbackHolder registration path)
- **Observed:** If a non-inline function is passed with synchronous=true, the registration succeeds but the callback never fires. No error, no warning, no console output.
- **Expected:** Should report a script error at registration time, e.g. "Synchronous callbacks require an inline function."

## Medium

### TransportHandler.setOn* -- no isRealtimeSafe() check for sync callbacks

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptingApi.cpp lines 8366-8536
- **Observed:** All five TransportHandler callback methods (`setOnTempoChange`, `setOnTransportChange`, `setOnSignatureChange`, `setOnBeatChange`, `setOnGridChange`) accept `SyncNotification` but do not check `isRealtimeSafe()` on the function argument. A non-inline function passed with sync=true will be invoked on the audio thread, which is unsafe.
- **Expected:** Should check `isRealtimeSafe()` on the callback function when sync=true, matching the pattern used by `GlobalCable.registerCallback` (ScriptingApiObjects.cpp line 9159).

### ScriptedMidiPlayer.setPlaybackCallback -- no isRealtimeSafe() check for sync callbacks

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp line 6807
- **Observed:** Accepts `SyncNotification` but does not check `isRealtimeSafe()` on the callback function. A non-inline function passed with sync=true will be invoked on the audio thread.
- **Expected:** Should check `isRealtimeSafe()` when sync=true.

### Message.setAllNotesOffCallback -- no isRealtimeSafe() check for always-audio callback

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptingApi.cpp line 1091
- **Observed:** This callback always runs on the audio thread via `callSync` but does not check `isRealtimeSafe()` at registration time. A non-inline function will be invoked on the audio thread.
- **Expected:** Should check `isRealtimeSafe()` on the callback function at registration time, matching the pattern used by `ScriptedMidiPlayer.setRecordEventCallback` (ScriptingApiObjects.cpp line 6464).

### ScriptFFT.setMagnitudeFunction / setPhaseFunction -- no isRealtimeSafe() check

- **Type:** missing-validation
- **Severity:** medium
- **Location:** ScriptingApiObjects.cpp lines 8100, 8113
- **Observed:** These callbacks run via `callSync` inside `process()` which is typically called from audio processing context. Neither checks `isRealtimeSafe()` at registration time.
- **Expected:** Should check `isRealtimeSafe()` on the callback function at registration time.

## Low

(No issues yet.)
