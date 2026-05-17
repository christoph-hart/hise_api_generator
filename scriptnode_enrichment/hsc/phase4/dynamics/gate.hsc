#!/usr/bin/env hise-cli run
# dynamics.gate: use a self-keyed gate to open a filtered noise texture while dry audio passes unchanged.
#
# Notes for this example:
# - dynamics.gate has no ProcessSignal switch, so the dry signal is kept on a separate split branch.
# - The gate branch analyses a duplicate input and then clears that duplicate audio.
# - The noise branch clears inherited split audio before generating its synthetic texture.
# - Gate modulation is gain-reduction amount, so NoiseGain uses a reversed target range.

/builder
reset

add ScriptFX as "NoiseLayerGate"
set NoiseLayerGate.network "noise_layer_gate"
/exit

/dsp
cd NoiseLayerGate

# Split into three branches: dry passthrough, gate analysis, and generated texture.
add container.split as "TextureSplit"
add container.chain as "DryPath" to TextureSplit
add container.chain as "GateControlPath" to TextureSplit
add dynamics.gate as "SelfGate" to GateControlPath

# Clear the gated duplicate so the control branch does not add audio to the split output.
add math.clear as "ControlClear" to GateControlPath

add container.chain as "NoisePath" to TextureSplit

# Clear inherited split audio first so the noise branch does not double the dry source.
add math.clear as "NoiseClear" to NoisePath

# Oscillator noise keeps the example compact; a looped noise file would often be better in production.
add core.oscillator as "NoiseSource" to NoisePath
add filters.svf_eq as "NoiseFilter" to NoisePath
add core.gain as "NoiseGain" to NoisePath

set NoiseSource.Mode 4
set NoiseSource.Gain 0.25
set NoiseFilter.Mode 1
set NoiseFilter.Frequency 2500
set NoiseFilter.Q 0.8

# Gate modulation is gain-reduction amount, so this reversed range maps open-gate activity toward audibility.
set NoiseGain.Gain.range [0, -100], NoiseGain.Gain.stepSize 0.1

# Disable gain smoothing so SelfGate.Release is the only release envelope demonstrated by the texture layer.
set NoiseGain.Smoothing 0

set SelfGate.Threshhold.range [-48, -18], SelfGate.Threshhold.stepSize 0.1
set SelfGate.Threshhold -30
set SelfGate.Release.range [20, 160], SelfGate.Release.stepSize 0.1
set SelfGate.Release 80
set SelfGate.Ratio.range [4, 16], SelfGate.Ratio.stepSize 0.1
set SelfGate.Ratio 10

create_parameter noise_layer_gate.GateThreshold [-48, -18] default -30 stepSize 0.1
create_parameter noise_layer_gate.GateRelease [20, 160] default 80 stepSize 0.1
create_parameter noise_layer_gate.GateDepth [4, 16] default 10 stepSize 0.1
connect noise_layer_gate.GateThreshold to SelfGate.Threshhold matched
connect noise_layer_gate.GateRelease to SelfGate.Release matched
connect noise_layer_gate.GateDepth to SelfGate.Ratio matched
connect SelfGate to NoiseGain.Gain

# Screenshot-oriented annotations and layout. Do not fold GateControlPath because it would hide SelfGate.
set SelfGate.NodeColour 0xFFE67E22
set SelfGate.Comment "**Self-keyed gate** - This duplicate input branch drives the gate modulation while the original dry branch stays untouched."

set TextureSplit.NodeColour 0xFF8F7766
set TextureSplit.Comment "Texture split keeps the dry source and control branch separate."

set GateControlPath.Comment "Control branch only. SelfGate analyses a dry copy and ControlClear removes duplicate audio."

set ControlClear.NodeColour 0xFF8F7766
set ControlClear.Comment "Clear the gated duplicate so only the dry branch reaches the output."

set NoiseClear.NodeColour 0xFF8F7766
set NoiseClear.Comment "Clear inherited signal before adding the synthetic noise layer."

set NoiseSource.NodeColour 0xFF8F7766
set NoiseSource.Comment "Oscillator noise keeps the example compact."

set NoiseFilter.NodeColour 0xFF8F7766
set NoiseGain.NodeColour 0xFF8F7766
set NoiseGain.Comment "Reversed target range maps gate reduction to open gate texture gain."

set DryPath.Folded true
set ControlClear.Folded true
set NoiseClear.Folded true
set NoiseSource.Folded true
set NoiseFilter.Folded true
/exit
