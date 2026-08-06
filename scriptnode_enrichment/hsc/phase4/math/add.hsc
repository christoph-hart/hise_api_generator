#!/usr/bin/env hise-cli run
# math.add: seed a known signal, add a public DC offset, inspect both stages, then clear it.
# The target node demonstrates raw linear offset rather than decibel gain.

/hise playground open
/builder
reset

add ScriptFX as "DcOffsetAdder"
set DcOffsetAdder.network "dc_offset_adder"
/exit

/dsp
cd DcOffsetAdder
add math.add as "SeedValue"
set SeedValue.Value 0.2
add analyse.specs as "InputSpecs"
add math.add as "OffsetAdder"
set OffsetAdder.Value.range [0, 0.5], OffsetAdder.Value.stepSize 0.01
set OffsetAdder.Value 0.3
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

create_parameter dc_offset_adder.DcOffset [0, 0.5] default 0.3
connect dc_offset_adder.DcOffset to OffsetAdder.Value matched

set OffsetAdder.NodeColour 0xFF2F80ED
set OffsetAdder.Comment "**DC offset adder** - Adds a raw scalar value to every sample."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
