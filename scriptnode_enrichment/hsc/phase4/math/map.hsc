#!/usr/bin/env hise-cli run
# math.map: remap a known value between ranges while demonstrating input clamping.

/hise playground open
/builder
reset

add ScriptFX as "ClampedRangeMapper"
set ClampedRangeMapper.network "clamped_range_mapper"
/exit

/dsp
cd ClampedRangeMapper
add math.add as "SeedValue"
set SeedValue.Value 0.8
add analyse.specs as "InputSpecs"
add math.map as "RangeMapper"
set RangeMapper.InputEnd.range [0.4, 0.8], RangeMapper.InputEnd 0.6
set RangeMapper.OutputStart.range [0, 0.3], RangeMapper.OutputStart 0.2
set RangeMapper.OutputEnd.range [0.6, 1], RangeMapper.OutputEnd 0.9
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

create_parameter clamped_range_mapper.InputEnd [0.4, 0.8] default 0.6
create_parameter clamped_range_mapper.OutputStart [0, 0.3] default 0.2
create_parameter clamped_range_mapper.OutputEnd [0.6, 1] default 0.9
connect clamped_range_mapper.InputEnd to RangeMapper.InputEnd matched
connect clamped_range_mapper.OutputStart to RangeMapper.OutputStart matched
connect clamped_range_mapper.OutputEnd to RangeMapper.OutputEnd matched

set RangeMapper.NodeColour 0xFF2F80ED
set RangeMapper.Comment "**Clamped range mapper** - Remaps a signal between ranges and clamps outside input bounds."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
