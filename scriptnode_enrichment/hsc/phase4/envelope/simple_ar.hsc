/hise playground open
/builder
reset
add ScriptFX as "TimerGatedArModulator"
set TimerGatedArModulator.network "timer_gated_ar_modulator"
/exit
/dsp
cd TimerGatedArModulator
add container.modchain as "InternalModHost"
add control.timer as "PulseTimer" to InternalModHost
set PulseTimer.Interval.range [125, 2000]
set PulseTimer.Interval 500
add math.fill1 as "EnvelopeSeed" to InternalModHost
add envelope.simple_ar as "ArEnvelope" to InternalModHost
set ArEnvelope.Attack.range [1, 150]
set ArEnvelope.Attack 10
set ArEnvelope.Release.range [20, 400]
set ArEnvelope.Release 120
set ArEnvelope.AttackCurve 0
add core.gain as "ModTarget"
create_parameter timer_gated_ar_modulator.Attack [1, 150] default 10
create_parameter timer_gated_ar_modulator.Release [20, 400] default 120
create_parameter timer_gated_ar_modulator.AttackCurve [0, 1] default 0
create_parameter timer_gated_ar_modulator.PulseRate [0.5, 8] default 2
connect PulseTimer to ArEnvelope.Gate
connect timer_gated_ar_modulator.Attack to ArEnvelope.Attack matched
connect timer_gated_ar_modulator.Release to ArEnvelope.Release matched
connect timer_gated_ar_modulator.AttackCurve to ArEnvelope.AttackCurve matched
connect timer_gated_ar_modulator.PulseRate to PulseTimer.Interval matched
connect ArEnvelope to ModTarget.Gain
/exit
