/hise playground open
/builder
reset
add ScriptFX as "ProductionHardClipper"
set ProductionHardClipper.network "production_hard_clipper"
# All distortion stages share 4x processing; analysis remains outside at the host rate.
/exit

/dsp
cd ProductionHardClipper
add container.oversample4x as "QuadRateClipper"
add math.mul as "PreGain" to QuadRateClipper
add math.clip as "HardClip" to QuadRateClipper
add math.mul as "OutputTrim" to QuadRateClipper
add analyse.fft as "OutputSpectrum"
set PreGain.Value.range [1, 8]
set PreGain.Value 4
set HardClip.Value 0.35
set OutputTrim.Value 0.5
create_parameter production_hard_clipper.Drive [1, 8] default 4
connect production_hard_clipper.Drive to PreGain.Value matched
# Keep math.clip in block processing because its frame implementation has different transfer behaviour.
set production_hard_clipper.Comment "**Block processing** - Keep math.clip out of frame containers because its single-sample implementation differs."
set QuadRateClipper.NodeColour 0xFFE67E22
set QuadRateClipper.Comment "**Practical 4x stage** - Drive, hard clipping, and trim are oversampled while analysis remains at the host rate."
set PreGain.NodeColour 0xFF8C6D55
set HardClip.NodeColour 0xFF8C6D55
set OutputTrim.NodeColour 0xFF8C6D55
set OutputSpectrum.NodeColour 0xFF8C6D55
set OutputSpectrum.Folded true
/exit
