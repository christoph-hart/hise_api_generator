/hise playground open
/builder
reset
add ScriptFX as "LightweightLargeBufferSubdivision"
set LightweightLargeBufferSubdivision.network "lightweight_large_buffer_subdivision"

# This is a technical zipper-noise comparison, not a recommendation for fast parameter modulation.
/exit

/dsp
cd LightweightLargeBufferSubdivision
add container.fix128_block as "OneTwentyEightBlocks"
# Inspection only: this node may be omitted without changing behavior.
add analyse.specs as "BlockInspector" to OneTwentyEightBlocks
add container.modchain as "StepControl" to OneTwentyEightBlocks
add core.ramp as "SourceRamp" to StepControl
# Fold the one-second ramp around its midpoint to make the coarse zipper steps easier to hear.
add math.sub as "CentreRamp" to StepControl
add math.abs as "FoldRamp" to StepControl
add core.peak as "ChunkValue" to StepControl
add math.add as "StaircaseOutput" to OneTwentyEightBlocks

set SourceRamp.PeriodTime 1000
set CentreRamp.Value 0.5
set StaircaseOutput.Value.range [0, 1]
connect ChunkValue to StaircaseOutput.Value

set OneTwentyEightBlocks.NodeColour 0xFF2F80ED
set BlockInspector.NodeColour 0xFF6F8FAF
set BlockInspector.Comment "Inspection only: displays the local 128-sample processing specification and may be omitted without changing behavior."
set StepControl.NodeColour 0xFF6F8FAF
set SourceRamp.NodeColour 0xFF6F8FAF
set CentreRamp.NodeColour 0xFF6F8FAF
set FoldRamp.NodeColour 0xFF6F8FAF
set ChunkValue.NodeColour 0xFF6F8FAF
set StaircaseOutput.NodeColour 0xFF6F8FAF
set CentreRamp.Folded true
set FoldRamp.Folded true
/exit
