/hise playground open
/builder
reset
add ScriptFX as "SelectableAntiAliasingQuality"
set SelectableAntiAliasingQuality.network "selectable_anti_aliasing_quality"
/exit

/dsp
cd SelectableAntiAliasingQuality
add container.oversample as "QualityResampler"
add math.expr as "SineFolder" to QualityResampler
set SineFolder.Code "Math.sin(input * (1.0f + value * 12.0f))"
set SineFolder.Value 0.7
add analyse.fft as "OutputSpectrum"
set QualityResampler.Oversampling.range [0, 4], QualityResampler.Oversampling.stepSize 1
set QualityResampler.Oversampling 2
# Quality is an exponent index: None, 2x, 4x, 8x, 16x. Changing it re-prepares the child chain.
create_parameter selectable_anti_aliasing_quality.Quality [0, 4] default 2 stepSize 1
connect selectable_anti_aliasing_quality.Quality to QualityResampler.Oversampling matched
# Expose Oversampling so the root Quality cable is visible on the inner container.
set QualityResampler.ShowParameters true
# Keep only the nonlinear stage oversampled. Unreported latency makes an uncompensated dry branch unsuitable.
set selectable_anti_aliasing_quality.Comment "**Serial topology** - Unreported resampler latency makes an uncompensated parallel dry path unsuitable."
set QualityResampler.NodeColour 0xFFE67E22
set QualityResampler.Comment "**Setup control** - Quality is an exponent index; changing it re-prepares only the nonlinear child chain."
set SineFolder.NodeColour 0xFF8C6D55
set OutputSpectrum.NodeColour 0xFF8C6D55
set OutputSpectrum.Folded true
/exit
