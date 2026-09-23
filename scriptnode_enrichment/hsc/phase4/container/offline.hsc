/hise playground open
/builder
reset
add ScriptFX as "EventDrivenControlPipeline"
set EventDrivenControlPipeline.network "event_driven_control_pipeline"

# Children receive preparation and reset, but no realtime process, frame, or MIDI callbacks.
/exit

/dsp
cd EventDrivenControlPipeline
add container.offline as "OfflineControls"
add control.cable_expr as "AmountCurve" to OfflineControls
add control.pma as "GainRange" to OfflineControls
# Keep the sample processor outside the offline container.
add math.mul as "AudioGain"

set AmountCurve.Code "input * input"
set GainRange.Multiply 0.8
set GainRange.Add 0.2
set AudioGain.Value.range [0, 1], AudioGain.Value.stepSize 0

create_parameter event_driven_control_pipeline.Amount [0, 1] default 0.5
connect event_driven_control_pipeline.Amount to AmountCurve.Value matched
connect AmountCurve to GainRange.Value
connect GainRange to AudioGain.Value

# cable_expr requires a compile-enabled network. Apply and verify HISE's status autofix if needed.
show status autofix
show status

set OfflineControls.NodeColour 0xFF7F8C8D
set OfflineControls.Comment "Children are prepared and reset but receive no realtime process, frame, or MIDI callbacks. Audio passes through unchanged."
set AmountCurve.NodeColour 0xFF687273
set AmountCurve.Comment "SNEX squares Amount. This cable node propagates parameter changes synchronously without realtime processing."
set GainRange.NodeColour 0xFF687273
set GainRange.Comment "Maps the squared control to 0.2..1.0 and immediately forwards it to AudioGain."
set AudioGain.NodeColour 0xFF687273
set AudioGain.Comment "The sample processor must remain outside OfflineControls; only its parameter is driven by the offline cable chain."
/exit
