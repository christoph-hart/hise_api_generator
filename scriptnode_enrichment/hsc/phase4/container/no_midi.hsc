/hise playground open
/builder
reset
add ScriptSynth as "MidiIsolatedTremoloLfo"
set MidiIsolatedTremoloLfo.network "midi_isolated_tremolo_lfo"

# modchain keeps the generated LFO signal out of the audible path.
/exit

/dsp
cd MidiIsolatedTremoloLfo
add container.modchain as "TremoloControl"
# no_midi blocks every event type only within this LFO subtree.
add container.no_midi as "MidiIsolation" to TremoloControl
add core.oscillator as "TremoloOscillator" to MidiIsolation
add math.sig2mod as "Normalise" to MidiIsolation
add math.mul as "TremoloDepth" to MidiIsolation
add core.peak as "TremoloPeak" to MidiIsolation

# These nodes remain outside no_midi and continue responding to notes.
add core.oscillator as "SawTone"
add envelope.simple_ar as "NoteEnvelope"
add envelope.voice_manager as "VoiceLifecycle"

set TremoloOscillator.Frequency.range [0.5, 8], TremoloOscillator.Frequency.stepSize 0
set TremoloOscillator.Frequency 4
set TremoloDepth.Value.range [0, 1], TremoloDepth.Value.stepSize 0
set TremoloDepth.Value 0.6
set SawTone.Mode 2
set SawTone.Gain.range [0.35, 1], SawTone.Gain.stepSize 0
set NoteEnvelope.Attack 10
set NoteEnvelope.Release 200

create_parameter midi_isolated_tremolo_lfo.Rate [0.5, 8] default 4
create_parameter midi_isolated_tremolo_lfo.Depth [0, 1] default 0.6
connect midi_isolated_tremolo_lfo.Rate to TremoloOscillator.Frequency matched
connect midi_isolated_tremolo_lfo.Depth to TremoloDepth.Value matched
connect TremoloPeak to SawTone.Gain
connect NoteEnvelope.1 to VoiceLifecycle."Kill Voice"

set MidiIsolation.NodeColour 0xFF27AE60
set MidiIsolation.Comment "Blocks every MIDI event type for this subtree, so each voice keeps a fixed 4 Hz LFO instead of tracking note pitch."
set TremoloControl.Comment "The mono modulation chain prevents the generated LFO signal from leaking into the audible stereo path."
set TremoloOscillator.NodeColour 0xFF668A73
set TremoloOscillator.Comment "One independent fixed-rate sine LFO is created for every active polyphonic voice."
set TremoloDepth.NodeColour 0xFF668A73
set TremoloDepth.Comment "Depth scales the normalized LFO before its peak value is exported to SawTone Gain."
set TremoloPeak.NodeColour 0xFF668A73
set SawTone.NodeColour 0xFF668A73
set SawTone.Comment "This oscillator stays outside no_midi, so incoming notes continue to set the audible pitch."
set NoteEnvelope.NodeColour 0xFF668A73
set NoteEnvelope.Comment "The envelope remains MIDI-enabled and articulates each synth voice independently."
set VoiceLifecycle.Comment "Ends each polyphonic voice after the envelope release reaches silence."
set Normalise.Folded true
set VoiceLifecycle.Folded true
/exit
