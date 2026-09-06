#!/usr/bin/env hise-cli run
# fx.bitcrush: degrade each repeat inside a feedback delay.

/hise playground open
/builder
reset
add ScriptFX as "CrushedEchoTrail"
set CrushedEchoTrail.network "crushed_echo_trail"
/exit

/dsp
cd CrushedEchoTrail
add template.feedback_delay as "EchoLoop"
add fx.bitcrush as "EchoCrusher" to EchoLoop
add filters.one_pole as "FeedbackTone" to EchoLoop
set EchoCrusher.index 1
set FeedbackTone.index 2
set EchoCrusher.Mode 1
set EchoCrusher.BitDepth.range [4, 12]
set EchoCrusher.BitDepth 7
set EchoLoop_fb_out.Feedback.range [0, 0.8]
set EchoLoop_fb_out.Feedback 0.45
set EchoLoop_delay.DelayTime.range [80, 600]
set EchoLoop_delay.DelayTime 240
create_parameter crushed_echo_trail.Bits [4, 12] default 7
create_parameter crushed_echo_trail.Feedback [0, 0.8] default 0.45
create_parameter crushed_echo_trail.DelayMs [80, 600] default 240
connect crushed_echo_trail.Bits to EchoCrusher.BitDepth matched
connect crushed_echo_trail.Feedback to EchoLoop_fb_out.Feedback matched
connect crushed_echo_trail.DelayMs to EchoLoop_delay.DelayTime matched
set EchoCrusher.NodeColour 0xFF2F80ED
set EchoLoop.NodeColour 0xFF6F8FAF
set FeedbackTone.Folded true
/exit
