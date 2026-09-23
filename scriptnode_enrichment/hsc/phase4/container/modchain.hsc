/hise playground open
/builder
reset
add ScriptFX as "ControlRateOscillatorVibrato"
set ControlRateOscillatorVibrato.network "control_rate_oscillator_vibrato"

# A fixed 32-sample wrapper increases updates from once per host block to every 32 audio samples.
/exit

/dsp
cd ControlRateOscillatorVibrato
add container.fix32_block as "Resolution32"
add container.modchain as "VibratoControl" to Resolution32
add core.ramp as "LfoRamp" to VibratoControl
add math.pi as "FullCycle" to VibratoControl
add math.sin as "SineShape" to VibratoControl
# Convert bipolar sine to 0..1 before peak, avoiding zero-crossing folding.
add math.sig2mod as "Normalise" to VibratoControl
add core.peak as "VibratoPeak" to VibratoControl
add core.oscillator as "SawTone" to Resolution32

set LfoRamp.PeriodTime.range [100, 2000]
set LfoRamp.PeriodTime 500
set FullCycle.Value.range [0, 2]
set FullCycle.Value 2
set SawTone.Mode 2
# The stock oscillator ratio step is integer. Set step size zero before applying subtle modulation.
set SawTone."Freq Ratio".range [0.98, 1.02], SawTone."Freq Ratio".stepSize 0, SawTone."Freq Ratio".middlePosition 1

create_parameter control_rate_oscillator_vibrato.Rate [100, 2000] default 500
connect control_rate_oscillator_vibrato.Rate to LfoRamp.PeriodTime matched
connect VibratoPeak to SawTone."Freq Ratio"

set Resolution32.NodeColour 0xFF7F6A91
set Resolution32.Comment "Constrains source and target to 32-sample blocks, so vibrato updates every 32 audio samples instead of once per host block."
set VibratoControl.NodeColour 0xFF8E44AD
set VibratoControl.Comment "Processes an isolated mono control buffer at one eighth of the parent sample rate and does not enter the stereo audio path."
set LfoRamp.NodeColour 0xFF7F6A91
set LfoRamp.Comment "PeriodTime is the full vibrato cycle in milliseconds."
set Normalise.Comment "Convert the bipolar sine to 0..1 before peak extraction so the negative half-cycle is not folded."
set VibratoPeak.NodeColour 0xFF7F6A91
set VibratoPeak.Comment "Exports the normalized control buffer into SawTone Freq Ratio range 0.98..1.02."
set SawTone.NodeColour 0xFF7F6A91
set SawTone.Comment "Freq Ratio uses a continuous fractional range; step size must be zero or the subtle vibrato is quantized away."
set FullCycle.Folded true
set SineShape.Folded true
set Normalise.Folded true
/exit
