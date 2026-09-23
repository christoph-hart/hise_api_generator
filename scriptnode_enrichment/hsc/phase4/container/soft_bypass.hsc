/hise playground open
/builder
reset
add ScriptFX as "ClickFreeVocalStrip"
set ClickFreeVocalStrip.network "click_free_vocal_strip"

# Use one wrapper around the complete serial strip. Series-chained soft bypass containers can click.
/exit

/dsp
cd ClickFreeVocalStrip
add container.soft_bypass as "VocalStrip"
add filters.one_pole as "HighPass" to VocalStrip
add dynamics.comp as "VocalCompressor" to VocalStrip
add math.mul as "SaturationDrive" to VocalStrip
add math.tanh as "SoftSaturation" to VocalStrip

set VocalStrip.SmoothingTime 40
set HighPass.Mode 1
set HighPass.Frequency 90
set HighPass.Smoothing 0.02
set VocalCompressor.Threshhold -18
set VocalCompressor.Ratio 3
set VocalCompressor.Attack 15
set VocalCompressor.Release 120
set SaturationDrive.Value.range [0, 2], SaturationDrive.Value.stepSize 0
set SaturationDrive.Value 1.5

create_parameter click_free_vocal_strip.StripEnable [0, 1] default 1 stepSize 1
# Bypass is a special power-button target, so matched range metadata is intentionally ignored.
connect click_free_vocal_strip.StripEnable to VocalStrip.Bypass matched
# Do not enable ShowParameters: the bypass cable is already visible at the power button.

set VocalStrip.NodeColour 0xFF27AE60
set VocalStrip.Comment "One smoothed wrapper crossfades the complete serial strip over 40 ms; do not series-chain soft bypass containers."
set HighPass.NodeColour 0xFF668A73
set VocalCompressor.NodeColour 0xFF668A73
set SoftSaturation.NodeColour 0xFF668A73
set SoftSaturation.Comment "The active strip applies high-pass filtering, compression, 1.5x drive, and soft saturation."
set click_free_vocal_strip.Comment "StripEnable 0 bypasses and 1 activates processing. Audio crossfades over SmoothingTime, but child modulation outputs stop immediately on bypass."
set SaturationDrive.Folded true
/exit
