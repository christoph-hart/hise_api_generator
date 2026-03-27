Modulator::getCurrentLevel() -> Double

Thread safety: SAFE -- reads display values written by the audio thread.
Read-only with no synchronization needed.
Returns the current display output value of the modulator. For PitchMode, the
raw pitch factor (0.5..2.0) is converted to 0.0..1.0 display range. Intended
for UI display; may lag behind actual audio-thread value by one buffer.

Dispatch/mechanics:
  m->getProcessor()->getDisplayValues().outL
  PitchMode: PitchConverters::pitchFactorToOutputValue() [0.5..2.0 -> 0..1]
  else: returns raw value

Anti-patterns:
  - Do NOT call from onControl or onNoteOn -- use a timer callback (30ms interval)
    for display polling. Value updates once per audio buffer.

Source:
  ScriptingApiObjects.cpp:3170  getCurrentLevel()
    -> getDisplayValues().outL with PitchMode conversion
