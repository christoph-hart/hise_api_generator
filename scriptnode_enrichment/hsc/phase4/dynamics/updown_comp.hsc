#!/usr/bin/env hise-cli run
# dynamics.updown_comp: calibrated OTT-style multiband compressor recreation.
#
# Each band has a local dry/wet template. The dry path must remain behind the
# crossover filters so it shares their phase and group-delay response with the
# processed path. A single top-level dry/wet mixer would bypass the split.
#
# All numeric DSP values below are intentionally hardcoded and calibrated to
# reproduce the OTT effect.

/hise playground open
/builder
reset

add ScriptFX as "OTTCompressor"
set OTTCompressor.network "ott_compressor"
/exit

/dsp
cd OTTCompressor

# Use the three-band frequency-split template.
add template.freq_split3 as "FrequencySplit"

# Each band gets its own dry/wet template to keep dry and wet paths phase matched.
add template.dry_wet as "LowBand" to FrequencySplit_band1
add math.mul as "LowPreGain" to LowBand_wet_path
add dynamics.updown_comp as "LowCompressor" to LowBand_wet_path
add math.mul as "LowPostGain" to LowBand_wet_path
remove LowBand_dummy
set LowPreGain.index 0
set LowCompressor.index 1
set LowPostGain.index 2

add template.dry_wet as "MidBand" to FrequencySplit_band2
add math.mul as "MidPreGain" to MidBand_wet_path
add dynamics.updown_comp as "MidCompressor" to MidBand_wet_path
add math.mul as "MidPostGain" to MidBand_wet_path
remove MidBand_dummy
set MidPreGain.index 0
set MidCompressor.index 1
set MidPostGain.index 2

add template.dry_wet as "HighBand" to FrequencySplit_band3
add math.mul as "HighPreGain" to HighBand_wet_path
add dynamics.updown_comp as "HighCompressor" to HighBand_wet_path
add math.mul as "HighPostGain" to HighBand_wet_path
remove HighBand_dummy
set HighPreGain.index 0
set HighCompressor.index 1
set HighPostGain.index 2

# Replace the template placeholders with the band-local dry/wet processing.
remove FrequencySplit_dummy1
remove FrequencySplit_dummy2
remove FrequencySplit_dummy3

# Calibrated crossover points.
set FrequencySplit_lr1_1.Frequency 88
set FrequencySplit_lr2_1.Frequency 88
set FrequencySplit_lr3_1.Frequency 88
set FrequencySplit_lr1_2.Frequency 2500
set FrequencySplit_lr2_2.Frequency 2500
set FrequencySplit_lr3_2.Frequency 2500

# Calibrated low-band gain staging and dual-threshold compression.
set LowPreGain.Value.range [0, 2]
set LowPostGain.Value.range [0, 6]
set LowPreGain.Value 0.69
set LowCompressor.LowThreshold -40.8
set LowCompressor.LowRatio 3.941296815520002
set LowCompressor.HighThreshold -33.8
set LowCompressor.HighRatio 65.06681640664662
set LowCompressor.Knee 0.1812000017549026
set LowCompressor.Attack 0
set LowCompressor.Release 305.4111685202056
set LowCompressor.RMS 1
set LowPostGain.Value 2.108

# Calibrated mid-band gain staging and dual-threshold compression.
set MidPreGain.Value.range [0, 2]
set MidPostGain.Value.range [0, 6]
set MidPreGain.Value 1.834
set MidCompressor.LowThreshold -42
set MidCompressor.LowRatio 5.351868752117148
set MidCompressor.HighThreshold -30.3
set MidCompressor.HighRatio 65.06681640664667
set MidCompressor.Knee 0.3
set MidCompressor.Attack 0.664653791202388
set MidCompressor.Release 280.8672311435491
set MidCompressor.RMS 0
set MidPostGain.Value 1.8004609375

# Calibrated high-band gain staging and dual-threshold compression.
set HighPreGain.Value.range [0, 2]
set HighPostGain.Value.range [0, 6]
set HighPreGain.Value 1.81
set HighCompressor.LowThreshold -37.6321556848105
set HighCompressor.LowRatio 4.17
set HighCompressor.HighThreshold -35.05200048966641
set HighCompressor.HighRatio 100
set HighCompressor.Knee 0.1175999981086471
set HighCompressor.Attack 2.095644181214617
set HighCompressor.Release 122.9679758241329
set HighCompressor.RMS 0
set HighPostGain.Value 3.27

# One global mix macro drives all three band-local dry/wet templates.
create_parameter ott_compressor.Mix [0, 1] default 1
connect ott_compressor.Mix to LowBand.DryWet matched
connect ott_compressor.Mix to MidBand.DryWet matched
connect ott_compressor.Mix to HighBand.DryWet matched

# Screenshot-oriented annotations and layout.
set LowCompressor.NodeColour 0xFFE67E22
set LowCompressor.Comment "**Low-band OTT compressor** - Calibrated upward and downward compression settings."
set MidCompressor.NodeColour 0xFFE67E22
set MidCompressor.Comment "**Mid-band OTT compressor** - Calibrated upward and downward compression settings."
set HighCompressor.NodeColour 0xFFE67E22
set HighCompressor.Comment "**High-band OTT compressor** - Calibrated upward and downward compression settings."

set FrequencySplit.NodeColour 0xFF8F7766
set FrequencySplit.Comment "Three-band Linkwitz-Riley split at 88 Hz and 2500 Hz."
set LowBand.NodeColour 0xFF8F7766
set LowBand.Comment "Band-local dry/wet keeps the dry path behind the crossover filters for phase and group-delay matching."
set MidBand.NodeColour 0xFF8F7766
set MidBand.Comment "Band-local dry/wet keeps the dry path behind the crossover filters for phase and group-delay matching."
set HighBand.NodeColour 0xFF8F7766
set HighBand.Comment "Band-local dry/wet keeps the dry path behind the crossover filters for phase and group-delay matching."

set LowPreGain.Folded true
set LowPostGain.Folded true
set MidPreGain.Folded true
set MidPostGain.Folded true
set HighPreGain.Folded true
set HighPostGain.Folded true
/exit
