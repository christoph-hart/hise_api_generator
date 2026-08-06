#!/usr/bin/env hise-cli run
# math.clear: erase inherited signal at the beginning of a split branch before adding a replacement layer.
# This demonstrates branch initialization, not merely muting the end of a chain.

/hise playground open
/builder
reset

add ScriptFX as "BranchLayerReset"
set BranchLayerReset.network "branch_layer_reset"
/exit

/dsp
cd BranchLayerReset
add container.split as "LayerSplit"
add container.chain as "DryBranch" to LayerSplit
add container.chain as "ReplacementBranch" to LayerSplit
add math.clear as "BranchReset" to ReplacementBranch
add core.oscillator as "ReplacementOsc" to ReplacementBranch
set ReplacementOsc.Frequency 220
add core.gain as "ReplacementTrim" to ReplacementBranch
set ReplacementTrim.Gain -12

set BranchReset.NodeColour 0xFF2F80ED
set BranchReset.Comment "**Branch initializer** - Clears inherited split audio before the replacement layer is generated."
set LayerSplit.NodeColour 0xFF6F8FAF
set ReplacementOsc.NodeColour 0xFF6F8FAF
set ReplacementTrim.NodeColour 0xFF6F8FAF
set DryBranch.Folded true
/exit
