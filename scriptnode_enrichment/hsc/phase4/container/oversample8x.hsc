/hise playground open
/builder
reset
add ScriptFX as "AggressiveSineFoldDistortion"
set AggressiveSineFoldDistortion.network "aggressive_sine_fold_distortion"
# Only the severe nonlinear stage receives the eightfold CPU multiplier.
/exit

/dsp
cd AggressiveSineFoldDistortion
add container.oversample8x as "EightRateFolder"
add math.expr as "SineFolder" to EightRateFolder
set SineFolder.Code "Math.sin(input * (1.0f + value * 14.0f))"
set SineFolder.Value 0.65
add analyse.fft as "OutputSpectrum"
create_parameter aggressive_sine_fold_distortion.Fold [0, 1] default 0.65
connect aggressive_sine_fold_distortion.Fold to SineFolder.Value matched
# Compare its spectrum and CPU against 4x before selecting this fixed factor.
set aggressive_sine_fold_distortion.Comment "**Quality check** - Compare against 4x before accepting the eightfold child CPU cost."
set EightRateFolder.NodeColour 0xFFE67E22
set EightRateFolder.Comment "**Severe nonlinearity only** - The sine folder is oversampled while spectrum analysis stays at the host rate."
set SineFolder.NodeColour 0xFF8C6D55
set OutputSpectrum.NodeColour 0xFF8C6D55
set OutputSpectrum.Folded true
/exit
