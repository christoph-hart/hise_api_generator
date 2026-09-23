/hise playground open
/builder
reset
add ScriptFX as "MidiPlayedFxSynth"
set MidiPlayedFxSynth.network "midi_played_fx_synth"

# Script FX children normally do not receive MIDI. midichain enables event delivery and timestamp splitting locally.
/exit

/dsp
cd MidiPlayedFxSynth
add container.midichain as "MidiEnabledSynth"
add core.oscillator as "SawTone" to MidiEnabledSynth
add envelope.simple_ar as "NoteEnvelope" to MidiEnabledSynth

set SawTone.Mode 2
# The oscillator remains gated on. MIDI retunes it while the envelope supplies articulation.
set NoteEnvelope.Attack.range [1, 250]
set NoteEnvelope.Attack 20
set NoteEnvelope.Release.range [20, 1000]
set NoteEnvelope.Release 250
set NoteEnvelope.AttackCurve 0.5

create_parameter midi_played_fx_synth.Attack [1, 250] default 20
create_parameter midi_played_fx_synth.Release [20, 1000] default 250
connect midi_played_fx_synth.Attack to NoteEnvelope.Attack matched
connect midi_played_fx_synth.Release to NoteEnvelope.Release matched

set MidiEnabledSynth.NodeColour 0xFF27AE60
set MidiEnabledSynth.Comment "A Script FX does not normally deliver MIDI to network children. midichain enables event delivery and sample-offset splitting inside this container."
set SawTone.NodeColour 0xFF668A73
set SawTone.Comment "MIDI retunes the oscillator but does not toggle its Gate; NoteEnvelope supplies note articulation."
set NoteEnvelope.NodeColour 0xFF668A73
set NoteEnvelope.Comment "The AR envelope responds to note events delivered by the surrounding midichain."
# Any future frame container must remain inside MidiEnabledSynth to inherit its MIDI-enabled context.
set midi_played_fx_synth.Comment "If frame processing is added later, put the frame container inside MidiEnabledSynth so it receives the enabled MIDI context."
/exit
