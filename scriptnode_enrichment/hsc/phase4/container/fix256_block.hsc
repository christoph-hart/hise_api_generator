/hise playground open
/builder
reset
add ScriptFX as "MinimalLargeBufferSplit"
set MinimalLargeBufferSplit.network "minimal_large_buffer_split"

# This large size is a technical zipper-noise comparison, not a recommendation for fast modulation.
/exit

/dsp
cd MinimalLargeBufferSplit
add container.fix256_block as "TwoFiftySixBlocks"
# Inspection only: this node may be omitted without changing behavior.
add analyse.specs as "BlockInspector" to TwoFiftySixBlocks
add container.modchain as "StepControl" to TwoFiftySixBlocks
add core.ramp as "SourceRamp" to StepControl
# Fold the one-second ramp around its midpoint to expose the coarse steps.
add math.sub as "CentreRamp" to StepControl
add math.abs as "FoldRamp" to StepControl
add core.peak as "ChunkValue" to StepControl
add math.add as "StaircaseOutput" to TwoFiftySixBlocks

set SourceRamp.PeriodTime 1000
set CentreRamp.Value 0.5
set StaircaseOutput.Value.range [0, 1]
connect ChunkValue to StaircaseOutput.Value

set TwoFiftySixBlocks.NodeColour 0xFF2F80ED
set BlockInspector.NodeColour 0xFF6F8FAF
set BlockInspector.Comment "Inspection only: displays the local 256-sample processing specification and may be omitted without changing behavior."
set StepControl.NodeColour 0xFF6F8FAF
set SourceRamp.NodeColour 0xFF6F8FAF
set CentreRamp.NodeColour 0xFF6F8FAF
set FoldRamp.NodeColour 0xFF6F8FAF
set ChunkValue.NodeColour 0xFF6F8FAF
set StaircaseOutput.NodeColour 0xFF6F8FAF
set CentreRamp.Folded true
set FoldRamp.Folded true
/exit
