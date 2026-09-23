/hise playground open
/builder
reset
add ScriptFX as "DynamicSawUnison"
set DynamicSawUnison.network "dynamic_saw_unison"
/exit

/dsp
cd DynamicSawUnison
# The offline horizontal container groups control-only nodes without processing audio.
add container.offline as "CloneControls"
set CloneControls.IsVertical false
# Clone-aware cables provide per-layer frequency ratio, pan, and gain values; ordinary clone parameters remain synchronized.
add control.clone_cable as "PitchSpread" to CloneControls
add control.clone_cable as "PanSpread" to CloneControls
add control.clone_cable as "GainCompensation" to CloneControls
# Parallel mode supplies silence to each clone generator and sums their outputs without multiplying input audio.
add container.clone as "UnisonLayers"
rename clone_child as "UnisonVoice"
add core.oscillator as "SawLayer" to UnisonVoice
add jdsp.jpanner as "LayerPan" to UnisonVoice

set UnisonLayers.SplitSignal 1
set PitchSpread.NumClones.range [1, 8], PitchSpread.NumClones.stepSize 1
set PanSpread.NumClones.range [1, 8], PanSpread.NumClones.stepSize 1
set GainCompensation.NumClones.range [1, 8], GainCompensation.NumClones.stepSize 1
set GainCompensation.Mode "Ducker"
set SawLayer.Mode 1
set SawLayer."Freq Ratio".range [0.5, 2], SawLayer."Freq Ratio".stepSize 0, SawLayer."Freq Ratio".middlePosition 1
set LayerPan.Rule 2
set SawLayer.NodeColour 0xFF5F7894
set LayerPan.NodeColour 0xFF5F7894

# Setting NumClones through the CLI silently rebuilds the first completed child into eight physical clone chains.
set UnisonLayers.NumClones.range [1, 8], UnisonLayers.NumClones.stepSize 1
set UnisonLayers.NumClones 8

# NumClones must be the first macro and use the same range on the clone container and all clone cables.
create_parameter dynamic_saw_unison.NumClones [1, 8] default 4 stepSize 1
create_parameter dynamic_saw_unison.Spread [0, 1] default 0.5
connect dynamic_saw_unison.NumClones to UnisonLayers.NumClones matched
connect dynamic_saw_unison.NumClones to PitchSpread.NumClones matched
connect dynamic_saw_unison.NumClones to PanSpread.NumClones matched
connect dynamic_saw_unison.NumClones to GainCompensation.NumClones matched
connect dynamic_saw_unison.Spread to PitchSpread.Value matched
connect dynamic_saw_unison.Spread to PanSpread.Value matched
connect PitchSpread to SawLayer."Freq Ratio"
connect PanSpread to LayerPan.Pan
connect GainCompensation to SawLayer.Gain
# Expose NumClones so its root cable is visible on the clone container.
set UnisonLayers.ShowParameters true

set UnisonLayers.NodeColour 0xFF8E44AD
set UnisonLayers.Comment "**Dynamic saw unison** - Parallel clones generate from silence and spread oscillator ratios from half-speed to double-speed."
set CloneControls.NodeColour 0xFF7F6A91
set CloneControls.Comment "Offline horizontal control strip: clone cables update targets without processing the audio buffer."
set PitchSpread.NodeColour 0xFF7F6A91
set PitchSpread.Comment "Spread distributes octave ratios from 0.5 to 2 across active clones."
set PanSpread.NodeColour 0xFF7F6A91
set PanSpread.Comment "Spread distributes stereo positions across active clones."
set GainCompensation.NodeColour 0xFF7F6A91
set GainCompensation.Comment "Ducker mode scales each oscillator by the reciprocal clone count."
/exit
