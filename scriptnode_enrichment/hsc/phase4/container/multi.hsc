/hise playground open
/builder
reset
add ScriptFX as "PerChannelStereoPanner"
set PerChannelStereoPanner.network "per_channel_stereo_panner"

/exit

/dsp
cd PerChannelStereoPanner
add control.xfader as "PanLaw"
# multi distributes disjoint channel slices rather than copying and summing audio.
add container.multi as "ChannelSlices"
add container.chain as "LeftChannel" to ChannelSlices
add math.mul as "LeftLevel" to LeftChannel
add container.chain as "RightChannel" to ChannelSlices
add math.mul as "RightLevel" to RightChannel

# RMS mode produces complementary constant-power coefficients.
set PanLaw.Mode RMS
create_parameter per_channel_stereo_panner.Pan [-1, 1] default 0
connect per_channel_stereo_panner.Pan to PanLaw.Value
connect PanLaw.0 to LeftLevel.Value
connect PanLaw.1 to RightLevel.Value

set ChannelSlices.NodeColour 0xFF2F80ED
set ChannelSlices.Comment "multi assigns disjoint channel slices; it does not copy and sum the stereo signal. Child 0 receives left and child 1 receives right."
set PanLaw.NodeColour 0xFF6F8FAF
set PanLaw.Comment "RMS mode generates complementary constant-power coefficients for the two channel-local multipliers."
set LeftChannel.Comment "First multi child: processes only input channel 0 (left)."
set RightChannel.Comment "Second multi child: processes only input channel 1 (right)."
set LeftLevel.NodeColour 0xFF6F8FAF
set RightLevel.NodeColour 0xFF6F8FAF
set per_channel_stereo_panner.Comment "The bipolar Pan macro is scaled from -1..1 to PanLaw Value 0..1: Left, Centre, Right."
/exit
