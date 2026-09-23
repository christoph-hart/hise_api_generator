/hise playground open
/builder
reset
add ScriptFX as "PhaseCancellationSilencer"
set PhaseCancellationSilencer.network "phase_cancellation_silencer"

# split copies the untouched input to every child and sums their aligned outputs.
/exit

/dsp
cd PhaseCancellationSilencer
add container.split as "CancellationPaths"
add math.mul as "PositivePath" to CancellationPaths
add math.mul as "InvertedPath" to CancellationPaths
# Widen the multiplier before setting the locked negative value.
set InvertedPath.Value.range [-1, 1], InvertedPath.Value.stepSize 0
set InvertedPath.Value -1

set CancellationPaths.NodeColour 0xFF2F80ED
set CancellationPaths.Comment "split copies the same aligned stereo input to both children, then sums their outputs."
set PositivePath.NodeColour 0xFF6F8FAF
set PositivePath.Comment "Passes the copied input unchanged at gain +1."
set InvertedPath.NodeColour 0xFF6F8FAF
set InvertedPath.Comment "Multiplies the second aligned copy by -1, producing exact cancellation without compensation gain."
/exit
