#!/usr/bin/env hise-cli run
# math.table: draw a transfer curve into an external Table slot and scan it with a slow ramp.

/hise playground open
/builder
reset

add ScriptFX as "DrawnTransferShaper"
set DrawnTransferShaper.network "drawn_transfer_shaper"
/exit

/dsp
cd DrawnTransferShaper
add core.ramp as "SlowRamp"
set SlowRamp.PeriodTime 1000
add math.table as "TableLookup"
# The table must be external because embedded complex data cannot be initialized from Interface script.
set_complex_data TableLookup.Table index 0
add core.peak as "OutputPeak"
add math.clear as "SignalClear"

set TableLookup.NodeColour 0xFF2F80ED
set TableLookup.Comment "**Drawn transfer shaper** - Reads a scripted external Table curve instead of an automatable parameter."
set SlowRamp.NodeColour 0xFF6F8FAF
set OutputPeak.NodeColour 0xFF6F8FAF
set SignalClear.Folded true
/exit

/script
/callback onInit
Content.makeFrontInterface(600, 600);

const var tableProcessor = Synth.getTableProcessor("DrawnTransferShaper");
const var tableData = tableProcessor.getTable(0);

tableData.reset();
tableData.addTablePoint(0.5, 0.3);
tableData.setTablePoint(2, 1.0, 1.0, 0.2);
/compile
/exit
