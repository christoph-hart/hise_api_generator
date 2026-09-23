/hise playground open
/builder
reset
add ScriptFX as "LightweightSoftSaturation"
set LightweightSoftSaturation.network "lightweight_soft_saturation"
# Keep gain staging and saturation together so all three stages share the doubled context.
/exit

/dsp
cd LightweightSoftSaturation
add container.oversample2x as "DoubleRateSaturation"
add math.mul as "PreGain" to DoubleRateSaturation
add math.tanh as "SoftClip" to DoubleRateSaturation
add math.mul as "OutputTrim" to DoubleRateSaturation
add analyse.fft as "OutputSpectrum"
# math.mul permits drive values above unity, unlike the tanh node's 0..1 Value range.
set PreGain.Value.range [1, 6]
set PreGain.Value 3
set OutputTrim.Value 0.4
create_parameter lightweight_soft_saturation.Drive [1, 6] default 3
connect lightweight_soft_saturation.Drive to PreGain.Value matched
# Bypass removes resampling but still runs this complete saturator at the host rate.
set lightweight_soft_saturation.Comment "**Serial topology** - Resampler latency is not reported, so this example has no uncompensated dry branch."
set DoubleRateSaturation.NodeColour 0xFFE67E22
set DoubleRateSaturation.Comment "**Complete gain stage** - Pre-gain, soft clipping, and output trim all share the doubled processing context."
set PreGain.NodeColour 0xFF8C6D55
set SoftClip.NodeColour 0xFF8C6D55
set OutputTrim.NodeColour 0xFF8C6D55
set OutputSpectrum.NodeColour 0xFF8C6D55
set OutputSpectrum.Folded true
/exit
