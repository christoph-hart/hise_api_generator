/hise playground open
/builder
reset
add ScriptFX as "DesignTimeBlockAudition"
set DesignTimeBlockAudition.network "design_time_block_audition"

# Legacy compatibility only: prefer a dynamic or static fixed-size block container for new networks.
/exit

/dsp
cd DesignTimeBlockAudition
add container.fix_blockx as "FixedBlocks"
# Inspection only: this node may be omitted without changing behavior.
add analyse.specs as "BlockInspector" to FixedBlocks
add container.modchain as "StepControl" to FixedBlocks
add core.ramp as "SourceRamp" to StepControl
add math.sub as "CentreRamp" to StepControl
add math.abs as "FoldRamp" to StepControl
add core.peak as "ChunkValue" to StepControl
add math.add as "StaircaseOutput" to FixedBlocks

set FixedBlocks.BlockSize 64
set SourceRamp.PeriodTime 1000
set CentreRamp.Value 0.5
set StaircaseOutput.Value.range [0, 1]
connect ChunkValue to StaircaseOutput.Value

set FixedBlocks.NodeColour 0xFF2F80ED
set FixedBlocks.Comment "**Legacy design-time block selector** - Prefer the dynamic block-size container for runtime selection or a static fixed-size container when the size is known."
set BlockInspector.NodeColour 0xFF6F8FAF
set BlockInspector.Comment "Inspection only: displays the property-selected local block size and may be omitted without changing behavior."
set StepControl.NodeColour 0xFF6F8FAF
set SourceRamp.NodeColour 0xFF6F8FAF
set CentreRamp.NodeColour 0xFF6F8FAF
set FoldRamp.NodeColour 0xFF6F8FAF
set ChunkValue.NodeColour 0xFF6F8FAF
set StaircaseOutput.NodeColour 0xFF6F8FAF
set CentreRamp.Folded true
set FoldRamp.Folded true
/exit
