#!/usr/bin/env hise-cli run
# math.pack: use a scripted external SliderPack slot as a visible lookup shaper.

/hise playground open
/builder
reset

add ScriptFX as "SliderPackLookupShaper"
set SliderPackLookupShaper.network "sliderpack_lookup_shaper"
/exit

/dsp
cd SliderPackLookupShaper
add core.ramp as "SlowRamp"
set SlowRamp.PeriodTime 1000
add math.pack as "PackLookup"
# The pack must be external because embedded complex data cannot be initialized from Interface script.
set_complex_data PackLookup.SliderPack index 0
add core.peak as "OutputPeak"
add math.clear as "SignalClear"

set PackLookup.NodeColour 0xFF2F80ED
set PackLookup.Comment "**SliderPack lookup shaper** - Reads a scripted external SliderPack as the user-facing shape."
set SlowRamp.NodeColour 0xFF6F8FAF
set OutputPeak.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit

/script
/callback onInit
Content.makeFrontInterface(600, 600);

const var packProcessor = Synth.getSliderPackProcessor("SliderPackLookupShaper");
const var packData = packProcessor.getSliderPack(0);

packData.setNumSliders(8);
packData.setAllValues([0.0, 0.85, 0.25, 1.0, 0.45, 0.7, 0.1, 0.55]);
/compile
/exit
