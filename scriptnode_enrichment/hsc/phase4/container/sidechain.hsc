/hise playground open
/builder
reset
add ScriptFX as "InternallyKeyedPumpingCompressor"
set InternallyKeyedPumpingCompressor.network "internally_keyed_pumping_compressor"

# sidechain appends a zeroed auxiliary pair internally; it is not a DAW sidechain input.
/exit

/dsp
cd InternallyKeyedPumpingCompressor
add container.sidechain as "InternalSidechain"
add container.multi as "FourChannelSlices" to InternalSidechain
# The first stereo slice intentionally passes the program signal unchanged.
add container.chain as "MainStereo" to FourChannelSlices
# The second stereo slice fills the initially silent auxiliary channels.
add container.no_midi as "KeyStereo" to FourChannelSlices
add core.oscillator as "PumpOscillator" to KeyStereo
add dynamics.comp as "PumpCompressor" to InternalSidechain

set PumpOscillator.Frequency.range [0.5, 8], PumpOscillator.Frequency.stepSize 0
set PumpOscillator.Frequency 2
set PumpCompressor.Sidechain 2
set PumpCompressor.Threshhold -24
set PumpCompressor.Ratio 8
set PumpCompressor.Attack 5
set PumpCompressor.Release 180
create_parameter internally_keyed_pumping_compressor.PumpRate [0.5, 8] default 2
connect internally_keyed_pumping_compressor.PumpRate to PumpOscillator.Frequency matched

set InternalSidechain.NodeColour 0xFFE67E22
set InternalSidechain.Comment "Appends a zeroed stereo auxiliary pair internally; this is not a DAW sidechain input, and only channels 0-1 leave the container."
set FourChannelSlices.NodeColour 0xFF8C6D55
set FourChannelSlices.Comment "The first child receives main channels 0-1; the second receives auxiliary channels 2-3."
set MainStereo.Comment "Intentionally empty so the original stereo pair reaches PumpCompressor unchanged."
set KeyStereo.NodeColour 0xFF8C6D55
set KeyStereo.Comment "Generates the internal stereo key and blocks MIDI so notes cannot retune it."
set PumpOscillator.NodeColour 0xFF8C6D55
set PumpCompressor.NodeColour 0xFF8C6D55
set PumpCompressor.Comment "Sidechain mode detects channels 2-3 while applying gain reduction only to channels 0-1."
set MainStereo.Folded true
/exit
