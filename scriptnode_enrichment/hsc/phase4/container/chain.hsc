/hise playground open
/builder
reset
add ScriptFX as "NestedMacroChain"
set NestedMacroChain.network "nested_macro_chain"
/exit

/dsp
cd NestedMacroChain
# The modchain keeps its generated ramp out of the audible stereo path.
add container.modchain as "SweepControl"
add core.ramp as "SweepRamp" to SweepControl
add core.peak as "SweepPeak" to SweepControl
add container.chain as "FilterAndLevel"
# Invert Sweep with PMA instead of reversing the shared macro range.
add control.pma as "GainInverter" to FilterAndLevel
add filters.svf as "MovingFilter" to FilterAndLevel
add core.gain as "OutputLevel" to FilterAndLevel

set SweepRamp.PeriodTime.range [0.1, 2000]
set SweepRamp.PeriodTime 2000
set GainInverter.Multiply -1
set GainInverter.Add 1
set MovingFilter.Smoothing 0.02
set MovingFilter.Frequency.range [200, 8000]
set OutputLevel.Gain.range [-12, -3]

# The nested macro is the modulation boundary and fans one source out to two targets.
create_parameter FilterAndLevel.Sweep [0, 1] default 0
connect FilterAndLevel.Sweep to MovingFilter.Frequency
connect FilterAndLevel.Sweep to GainInverter.Value
# The PMA inversion lowers output as the filter opens.
connect GainInverter to OutputLevel.Gain
connect SweepPeak to FilterAndLevel.Sweep

set FilterAndLevel.NodeColour 0xFF2F80ED
set FilterAndLevel.Comment "**Nested macro chain** - Sweep fans one normalised control value out to cutoff and inverse output level."
set SweepControl.NodeColour 0xFF6F8FAF
set SweepControl.Comment "The modchain generates a mono control ramp without leaking it into the audible stereo path."
set SweepPeak.NodeColour 0xFF6F8FAF
set GainInverter.NodeColour 0xFF6F8FAF
set GainInverter.Comment "Invert Sweep before gain mapping so the level falls while the filter opens."
set MovingFilter.NodeColour 0xFF6F8FAF
set OutputLevel.NodeColour 0xFF6F8FAF
set SweepRamp.Folded true
/exit
