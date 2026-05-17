#!/usr/bin/env hise-cli run
# dynamics.limiter: catch non-linear shaper peaks with a final safety limiter.
#
# Notes for this example:
# - DriveShaper uses a fixed cubic expression so the limiter has visible peaks to catch.
# - math.expr requires HISE's compile-enabled network flag; setting Code now applies that
#   runtime graph fix automatically.
# - SafetyLimiter is placed last so it reads as a final peak-safety stage.
# - Attack is fixed because changing limiter attack changes lookahead latency and can click at runtime.

/builder
reset

add ScriptFX as "SafetyPeakLimiter"
set SafetyPeakLimiter.network "safety_peak_limiter"
/exit

/dsp
cd SafetyPeakLimiter
add math.expr as "DriveShaper"

# Place the limiter after the non-linear shaper so it acts as a final safety stage.
add dynamics.limiter as "SafetyLimiter"

# Lock the shaper expression to a simple cubic curve that compiles cleanly in SNEX.
set DriveShaper.Code "input + value * input * input * input"
set DriveShaper.Value.range [0, 0.75], DriveShaper.Value.stepSize 0.01
set DriveShaper.Value 0.5

# Fixed lookahead/latency choice, not a performance macro.
set SafetyLimiter.Attack 5
set SafetyLimiter.Threshhold.range [-12, -1], SafetyLimiter.Threshhold.stepSize 0.1
set SafetyLimiter.Threshhold -3
set SafetyLimiter.Release.range [20, 180], SafetyLimiter.Release.stepSize 0.1
set SafetyLimiter.Release 90
set SafetyLimiter.Ratio.range [12, 32], SafetyLimiter.Ratio.stepSize 0.1
set SafetyLimiter.Ratio 20

create_parameter safety_peak_limiter.DriveAmount [0, 0.75] default 0.5 stepSize 0.01
create_parameter safety_peak_limiter.LimitThreshold [-12, -1] default -3 stepSize 0.1
create_parameter safety_peak_limiter.LimitRelease [20, 180] default 90 stepSize 0.1
create_parameter safety_peak_limiter.LimitRatio [12, 32] default 20 stepSize 0.1
connect safety_peak_limiter.DriveAmount to DriveShaper.Value matched
connect safety_peak_limiter.LimitThreshold to SafetyLimiter.Threshhold matched
connect safety_peak_limiter.LimitRelease to SafetyLimiter.Release matched
connect safety_peak_limiter.LimitRatio to SafetyLimiter.Ratio matched

# Screenshot-oriented annotations and layout.
set DriveShaper.NodeColour 0xFF8F7766
set DriveShaper.Comment "DriveShaper adds cubic colour before the limiter so the safety stage has real overs to catch."

set SafetyLimiter.NodeColour 0xFFE67E22
set SafetyLimiter.Comment "**Peak safety limiter** - Final stage catches shaper peaks. Attack is fixed because it changes lookahead latency."
/exit
