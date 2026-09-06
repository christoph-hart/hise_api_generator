#!/usr/bin/env hise-cli run
# fx.sampleandhold: hold noise samples to create a stepped texture.

/hise playground open
/builder
reset
add ScriptFX as "SteppedNoiseTexture"
set SteppedNoiseTexture.network "stepped_noise_texture"
/exit

/dsp
cd SteppedNoiseTexture
add core.oscillator as "NoiseSource"
set NoiseSource.Mode 4
set NoiseSource.Gain 0.25
add fx.sampleandhold as "StepHolder"
set StepHolder.Counter.range [2, 64]
set StepHolder.Counter 16
add core.gain as "TextureTrim"
set TextureTrim.Gain -12
create_parameter stepped_noise_texture.Counter [2, 64] default 16
connect stepped_noise_texture.Counter to StepHolder.Counter matched
set StepHolder.NodeColour 0xFF2F80ED
set NoiseSource.NodeColour 0xFF6F8FAF
/exit
