/hise playground open
/builder
reset
add ScriptFX as "ExtremeFoldbackStressTest"
set ExtremeFoldbackStressTest.network "extreme_foldback_stress_test"
# Only the pathological nonlinear stage receives the sixteenfold CPU multiplier.
/exit

/dsp
cd ExtremeFoldbackStressTest
add container.oversample16x as "SixteenRateStress"
add math.expr as "NestedSineStress" to SixteenRateStress
set NestedSineStress.Code "Math.sin(Math.sin(input * (1.0f + value * 12.0f)) * 8.0f)"
set NestedSineStress.Value 0.7
add analyse.fft as "OutputSpectrum"
create_parameter extreme_foldback_stress_test.Stress [0, 1] default 0.7
connect extreme_foldback_stress_test.Stress to NestedSineStress.Value matched
# Treat 16x as a diagnostic upper bound and compare it against matched 4x and 8x captures.
set extreme_foldback_stress_test.Comment "**16x diagnostic** - Reserve this factor for cases where matched 4x and 8x comparisons still leave audible aliasing."
set SixteenRateStress.NodeColour 0xFFE74C3C
set SixteenRateStress.Comment "**Extreme CPU cost** - Only the nested sine stress stage runs at sixteen times the host rate."
set NestedSineStress.NodeColour 0xFF965E58
set OutputSpectrum.NodeColour 0xFF965E58
set OutputSpectrum.Folded true
/exit
