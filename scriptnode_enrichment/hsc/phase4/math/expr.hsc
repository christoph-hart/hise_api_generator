#!/usr/bin/env hise-cli run
# math.expr: compile a small SNEX clip expression and expose its width as a root parameter.

/hise playground open
/builder
reset

add ScriptFX as "ProgrammableScalarTransform"
set ProgrammableScalarTransform.network "programmable_scalar_transform"
/exit

/dsp
cd ProgrammableScalarTransform
add math.add as "SeedValue"
set SeedValue.Value 0.5
add analyse.specs as "InputSpecs"
add math.expr as "ShapeExpr"
set ShapeExpr.Value.range [0.2, 0.8]
set ShapeExpr.Value 0.4
# Use explicit float literals in the one-line SNEX formula to avoid type mismatch warnings.
set ShapeExpr.Code "input > value ? value : (input < -1.0f * value ? -1.0f * value : input)"
add analyse.specs as "OutputSpecs"
add math.clear as "SignalClear"

create_parameter programmable_scalar_transform.ClipWidth [0.2, 0.8] default 0.4
connect programmable_scalar_transform.ClipWidth to ShapeExpr.Value matched

set ShapeExpr.NodeColour 0xFF2F80ED
set ShapeExpr.Comment "**Programmable scalar transform** - A one-line SNEX expression clips the signal to the public width parameter."
set SeedValue.NodeColour 0xFF6F8FAF
set InputSpecs.NodeColour 0xFF6F8FAF
set OutputSpecs.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit
