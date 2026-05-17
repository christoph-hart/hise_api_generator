#!/usr/bin/env hise-cli run
# dynamics.comp: duck a stereo program signal from a synthetic sidechain detector pair.
#
# Notes for this example:
# - container.sidechain expands stereo into four internal channels: program 0-1 and detector 2-3.
# - container.multi exposes those stereo pairs visually; it is not a dry/wet split.
# - The detector pair is cleared before the synthetic ramp replaces it.
# - DuckComp.Sidechain must be set to Sidechain, otherwise the compressor becomes ordinary self-keyed compression.

/builder
reset

add ScriptFX as "SidechainDucker"
set SidechainDucker.network "sidechain_ducker"
/exit

/dsp
cd SidechainDucker

# SidechainHost expands stereo into an internal four-channel layout for DuckComp.
add container.sidechain as "SidechainHost"

# PairView exposes the program and detector stereo pairs; it is not a dry/wet split.
add container.multi as "PairView" to SidechainHost
add container.chain as "ProgramPair" to PairView
add container.chain as "SidechainPair" to PairView

# Clear the duplicated detector pair before replacing it with the synthetic pump ramp.
add math.clear as "DetectorClear" to SidechainPair

# PumpTime controls the ramp period directly.
add core.ramp as "PumpRamp" to SidechainPair
add dynamics.comp as "DuckComp" to SidechainHost

set PumpRamp.PeriodTime.range [250, 4000], PumpRamp.PeriodTime.stepSize 1
set PumpRamp.PeriodTime 1000

# Sidechain mode is required; Disabled and Original collapse this into self-keyed compression.
set DuckComp.Sidechain 2
set DuckComp.Threshhold.range [-36, -12], DuckComp.Threshhold.stepSize 0.1
set DuckComp.Threshhold -24
set DuckComp.Release.range [40, 220], DuckComp.Release.stepSize 0.1
set DuckComp.Release 140
set DuckComp.Ratio.range [2, 12], DuckComp.Ratio.stepSize 0.1
set DuckComp.Ratio 6

create_parameter sidechain_ducker.DuckThreshold [-36, -12] default -24 stepSize 0.1
create_parameter sidechain_ducker.DuckRelease [40, 220] default 140 stepSize 0.1
create_parameter sidechain_ducker.DuckRatio [2, 12] default 6 stepSize 0.1
create_parameter sidechain_ducker.PumpTime [250, 4000] default 1000 stepSize 1
connect sidechain_ducker.DuckThreshold to DuckComp.Threshhold matched
connect sidechain_ducker.DuckRelease to DuckComp.Release matched
connect sidechain_ducker.DuckRatio to DuckComp.Ratio matched
connect sidechain_ducker.PumpTime to PumpRamp.PeriodTime matched

# Screenshot-oriented annotations and layout. Do not fold SidechainPair because it would hide PumpRamp.
set DuckComp.NodeColour 0xFFE67E22
set DuckComp.Comment "**Sidechain compressor** - DuckComp listens to the synthetic detector pair while compressing the program pair."

set SidechainHost.NodeColour 0xFF8F7766
set SidechainHost.Comment "SidechainHost expands stereo into four internal channels: program 0-1 and detector 2-3."

set PairView.NodeColour 0xFF8F7766
set PairView.Comment "PairView exposes the two stereo pairs before DuckComp processes the full four-channel stream."

set DetectorClear.NodeColour 0xFF8F7766
set DetectorClear.Comment "Clear the duplicated detector pair before replacing it with the synthetic pump ramp."

set PumpRamp.NodeColour 0xFF8F7766
set PumpRamp.Comment "Pump time controls the ramp period for wider ducking cycles."

set ProgramPair.Folded true
set DetectorClear.Folded true
/exit
