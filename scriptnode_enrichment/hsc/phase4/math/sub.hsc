#!/usr/bin/env hise-cli run
# math.sub: seed a known signal, subtract a public DC offset, inspect both stages, then clear it.

/hise playground open
/builder
reset

add ScriptFX as "DcSubtractor"
set DcSubtractor.network "dc_subtractor"
/exit

/dsp
cd DcSubtractor
add math.add as "SeedValue"
set SeedValue.Value 0.8
add analyse.specs as "InputSpecs"
add math.sub as "OffsetSubtractor"
set OffsetSubtractor.Value.range [0, 0.5], OffsetSubtractor.Value.stepSize 0.01
set OffsetSubtractor.Value 0.2
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

create_parameter dc_subtractor.Offset [0, 0.5] default 0.2
connect dc_subtractor.Offset to OffsetSubtractor.Value matched

set OffsetSubtractor.NodeColour 0xFF2F80ED
set OffsetSubtractor.Comment "**DC subtractor** - Removes a raw scalar offset from every sample."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
