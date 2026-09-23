/hise playground open
/builder
reset
add ScriptFX as "SlowlyEvolvingFilterTone"
set SlowlyEvolvingFilterTone.network "slowly_evolving_filter_tone"

# Sixty-four samples is the default starting size for adjustable block containers and is sufficient for slow modulation.
/exit

/dsp
cd SlowlyEvolvingFilterTone
add container.fix64_block as "SixtyFourSampleMotion"
add control.smoothed_parameter as "ToneSmoother" to SixtyFourSampleMotion
add filters.svf as "EvolvingLowPass" to SixtyFourSampleMotion

set ToneSmoother.Mode "Linear Ramp"
set ToneSmoother.SmoothingTime 1000
# Configure the skewed target range before connecting the normalised smoother output.
set EvolvingLowPass.Frequency.range [200, 8000], EvolvingLowPass.Frequency.middlePosition 1000
set EvolvingLowPass.Frequency 200
set EvolvingLowPass.Q 0.7
# Keep this at zero so only ToneSmoother defines the transition.
set EvolvingLowPass.Smoothing 0

create_parameter slowly_evolving_filter_tone.Tone [0, 1] default 0.25
connect slowly_evolving_filter_tone.Tone to ToneSmoother.Value matched
connect ToneSmoother to EvolvingLowPass.Frequency

set SixtyFourSampleMotion.NodeColour 0xFF2F80ED
set SixtyFourSampleMotion.Comment "**Slowly evolving filter tone** - Sixty-four-sample chunks are sufficient for a one-second smoothed cutoff transition with low iteration overhead."
set ToneSmoother.NodeColour 0xFF6F8FAF
set ToneSmoother.Comment "Linear Ramp turns abrupt Tone changes into an exact one-second transition before the filter is updated."
set EvolvingLowPass.NodeColour 0xFF6F8FAF
set EvolvingLowPass.Comment "Its 200 to 8000 Hz range must be configured before connecting; Smoothing remains zero to avoid a second interpolation stage."
/exit
