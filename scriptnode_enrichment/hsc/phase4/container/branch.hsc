/hise playground open
/builder
reset
add ScriptFX as "SelectableWaveshaper"
set SelectableWaveshaper.network "selectable_waveshaper"
/exit

/dsp
cd SelectableWaveshaper
# Only the selected prepared child processes audio, and Index switches immediately without a crossfade.
add container.branch as "ShapeModes"
add math.expr as "TanhShape" to ShapeModes
add math.expr as "HiseSaturation" to ShapeModes
add math.expr as "SineFold" to ShapeModes

# Lock each amount so Mode compares transfer functions rather than unrelated gain settings.
set TanhShape.Code "Math.tanh(input * (1.0f + value * 5.0f))"
set TanhShape.Value 0.5
set HiseSaturation.Code "(1.0f + value / (1.0f - value)) * input / (1.0f + value / (1.0f - value) * Math.abs(input))"
set HiseSaturation.Value 0.75
set SineFold.Code "Math.sin(input * (1.0f + value * 8.0f))"
set SineFold.Value 0.5
set ShapeModes.Index.range [0, 2], ShapeModes.Index.stepSize 1

create_parameter selectable_waveshaper.Mode [0, 2] default 0 stepSize 1
connect selectable_waveshaper.Mode to ShapeModes.Index matched
# Expose Index so the root Mode cable is visible on the inner container.
set ShapeModes.ShowParameters true

set ShapeModes.NodeColour 0xFFE67E22
set ShapeModes.Comment "**Selectable waveshaper** - Only the child selected by Mode processes audio; switching is immediate without a crossfade."
set TanhShape.NodeColour 0xFF8C6D55
set TanhShape.Comment "Tanh transfer with a locked amount for a consistent algorithm comparison."
set HiseSaturation.NodeColour 0xFF8C6D55
set HiseSaturation.Comment "HISE-style rational saturation with a locked amount."
set SineFold.NodeColour 0xFF8C6D55
set SineFold.Comment "Sine folding transfer with a locked amount."
/exit
