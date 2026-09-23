/hise playground open
/builder
reset
add ScriptFX as "AdjustableModulationStaircase"
set AdjustableModulationStaircase.network "adjustable_modulation_staircase"
/exit

/dsp
cd AdjustableModulationStaircase
# BlockSize is an index into [1, 8, 16, 32, 64, 128, 256, 512], not a sample count.
add container.dynamic_blocksize as "AdjustableBlocks"
# Inspection only: BlockInspector displays local specs and may be omitted without changing behavior.
add analyse.specs as "BlockInspector" to AdjustableBlocks
# The modulation source and target remain inside the dynamic container so they share its cadence.
add container.modchain as "StepControl" to AdjustableBlocks
add core.ramp as "SourceRamp" to StepControl
# Subtract 0.5 and take the absolute value to fold the one-second ramp into an audible triangular staircase.
add math.sub as "CentreRamp" to StepControl
add math.abs as "FoldRamp" to StepControl
add core.peak as "ChunkValue" to StepControl
# This additive stage intentionally turns the held control value into a DC-rich audible staircase.
add math.add as "StaircaseOutput" to AdjustableBlocks

set SourceRamp.PeriodTime 1000
set CentreRamp.Value 0.5
set StaircaseOutput.Value.range [0, 1]
create_parameter adjustable_modulation_staircase.BlockSize [0, 7] default 4 stepSize 1
connect adjustable_modulation_staircase.BlockSize to AdjustableBlocks.BlockSize matched
# Expose BlockSize so the root cable is visible on the inner container.
set AdjustableBlocks.ShowParameters true
connect ChunkValue to StaircaseOutput.Value

set AdjustableBlocks.NodeColour 0xFF2F80ED
set AdjustableBlocks.Comment "**Adjustable modulation staircase** - BlockSize selects child processing chunks from one sample through 512 samples."
set BlockInspector.NodeColour 0xFF6F8FAF
set BlockInspector.Comment "Inspection only: displays local processing specifications and does not affect signal flow or block-size behavior."
set StepControl.NodeColour 0xFF6F8FAF
set StepControl.Comment "The one-second ramp is folded into a slow triangle so coarse block updates become audible zipper steps."
set SourceRamp.NodeColour 0xFF6F8FAF
set CentreRamp.NodeColour 0xFF6F8FAF
set FoldRamp.NodeColour 0xFF6F8FAF
set ChunkValue.NodeColour 0xFF6F8FAF
set StaircaseOutput.NodeColour 0xFF6F8FAF
set CentreRamp.Folded true
set FoldRamp.Folded true
/exit
