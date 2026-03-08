MidiPlayer::getTimeSignature() -> JSON

Thread safety: UNSAFE -- Constructs a DynamicObject on the heap.
Returns the time signature of the current sequence as a JSON object with properties: Nominator, Denominator, NumBars, LoopStart, LoopEnd, Tempo. Internally delegates to getTimeSignatureFromSequence(-1).
Required setup:
```
const var mp = Synth.getMidiPlayer("MidiPlayer1");
var sig = mp.getTimeSignature();
```
Pair with: MidiPlayer.setTimeSignature -- set time signature. MidiPlayer.getTimeSignatureFromSequence -- get from a specific sequence.
Source:
  ScriptingApiObjects.cpp:6250  getTimeSignature() -> getTimeSignatureFromSequence(-1) -> HiseMidiSequence::TimeSignature::getAsJSON()
