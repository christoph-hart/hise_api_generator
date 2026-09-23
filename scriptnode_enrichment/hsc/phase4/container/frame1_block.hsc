/hise playground open
/builder
reset
add ScriptFX as "AntiphaseStereoChorus"
set AntiphaseStereoChorus.network "antiphase_stereo_chorus"
# Add a direct MIDI audition source for the chorus.
add WaveSynth as "Waveform Generator"

/exit

/dsp
cd AntiphaseStereoChorus
add template.dry_wet as "ChorusMix"
add container.multi as "StereoWetChannels" to ChorusMix_wet_path
remove ChorusMix_dummy
# Preserve the template wet gain and keep it after the stereo frame processor.
set StereoWetChannels.index 0
set ChorusMix_wet_gain.index 1

# Each multi child receives one mono channel, making frame1 safe in a default stereo host.
add container.frame1_block as "LeftFrames" to StereoWetChannels
add container.modchain as "LeftDelayLfo" to LeftFrames
add core.ramp as "LeftRamp" to LeftDelayLfo
add math.pi as "LeftCycle" to LeftDelayLfo
add math.sin as "LeftSine" to LeftDelayLfo
add math.sig2mod as "LeftNormalise" to LeftDelayLfo
add core.peak as "LeftDelayControl" to LeftDelayLfo
add jdsp.jdelay_cubic as "LeftDelay" to LeftFrames

add container.frame1_block as "RightFrames" to StereoWetChannels
add container.modchain as "RightDelayLfo" to RightFrames
add core.ramp as "RightRamp" to RightDelayLfo
add math.pi as "RightCycle" to RightDelayLfo
add math.sin as "RightSine" to RightDelayLfo
# Invert the bipolar sine before normalization so the right delay moves opposite to the left.
add math.mul as "InvertRight" to RightDelayLfo
add math.sig2mod as "RightNormalise" to RightDelayLfo
add core.peak as "RightDelayControl" to RightDelayLfo
add jdsp.jdelay_cubic as "RightDelay" to RightFrames

set LeftRamp.PeriodTime.range [200, 6000]
set LeftRamp.PeriodTime 5000
set RightRamp.PeriodTime.range [200, 6000]
set RightRamp.PeriodTime 5000
set InvertRight.Value.range [-1, 1]
set InvertRight.Value -1
set LeftDelay.Limit 20
# Set a linear midpoint explicitly; retaining the original delay skew would make complementary values asymmetric.
set LeftDelay.DelayTime.range [4, 10], LeftDelay.DelayTime.middlePosition 7
set RightDelay.Limit 20
set RightDelay.DelayTime.range [4, 10], RightDelay.DelayTime.middlePosition 7
connect LeftDelayControl to LeftDelay.DelayTime
connect RightDelayControl to RightDelay.DelayTime

create_parameter antiphase_stereo_chorus.Rate [200, 6000] default 5000 stepSize 0.1
create_parameter antiphase_stereo_chorus.Mix [0, 1] default 0.5
create_parameter antiphase_stereo_chorus.LfoGate [0, 1] default 1 stepSize 1
connect antiphase_stereo_chorus.Rate to LeftRamp.PeriodTime matched
connect antiphase_stereo_chorus.Rate to RightRamp.PeriodTime matched
connect antiphase_stereo_chorus.Mix to ChorusMix.DryWet matched
connect antiphase_stereo_chorus.LfoGate to LeftRamp.Gate matched
connect antiphase_stereo_chorus.LfoGate to RightRamp.Gate matched
# Expose DryWet so the root Mix cable is visible on the inner template container.
set ChorusMix.ShowParameters true
# Restart both independently created ramps on one shared parameter callback.
set antiphase_stereo_chorus.LfoGate 0
set antiphase_stereo_chorus.LfoGate 1

# This warning is load-bearing documentation for interpreted use.
set antiphase_stereo_chorus.Comment "**CPU warning** - Two interpreted frame1 branches are extremely expensive. Compile this network to a C++ node before practical use."
set ChorusMix.NodeColour 0xFF7F6A91
set ChorusMix.Comment "**Antiphase stereo chorus** - The module-tree WaveSynth provides an immediate audition source for two independent mono frame-processed delay paths."
set StereoWetChannels.NodeColour 0xFF7F6A91
set StereoWetChannels.Comment "Splits default stereo into one mono frame1 processor for each channel."
set LeftFrames.NodeColour 0xFF8E44AD
set LeftFrames.Comment "Processes the left channel with one DelayTime update per sample."
set RightFrames.NodeColour 0xFF8E44AD
set RightFrames.Comment "Processes the right channel with polarity-inverted sample-accurate modulation."
set LeftDelayLfo.NodeColour 0xFF7F6A91
set RightDelayLfo.NodeColour 0xFF7F6A91
set LeftDelay.NodeColour 0xFF7F6A91
set RightDelay.NodeColour 0xFF7F6A91
set LeftCycle.Folded true
set LeftSine.Folded true
set LeftNormalise.Folded true
set LeftDelayControl.Folded true
set RightCycle.Folded true
set RightSine.Folded true
set InvertRight.Folded true
set RightNormalise.Folded true
set RightDelayControl.Folded true
set ChorusMix_wet_gain.Folded true
/exit
