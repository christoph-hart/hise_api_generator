# fx.bitcrush - HSC Construction Artifact

## Source

- Phase 2: `scriptnode_enrichment/hsc/phase2/fx/bitcrush.md`
- Reference: `scriptnode_enrichment/output/fx/bitcrush.md`

## Status

- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully in a ScriptFX feedback network.

## Naming

- Module ID: `CrushedEchoTrail`
- Network ID: `crushed_echo_trail`

## Builder Setup Applied

- Host context: `Script FX`
- Additional builder steps applied: inserted the crusher and tone stage into the feedback template block.
- Channel/routing setup verified: default stereo routing.

## Verified Parameters

- `EchoCrusher.Mode` = `1` (Bipolar)
- `EchoCrusher.BitDepth` = `7`, range `[4, 12]`
- `EchoLoop_fb_out.Feedback` = `0.45`, range `[0, 0.8]`
- `EchoLoop_delay.DelayTime` = `240`, range `[80, 600]`

## Verified Connections

- `crushed_echo_trail.Bits -> EchoCrusher.BitDepth` matched
- `crushed_echo_trail.Feedback -> EchoLoop_fb_out.Feedback` matched
- `crushed_echo_trail.DelayMs -> EchoLoop_delay.DelayTime` matched

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id CrushedEchoTrail --agent
hise-cli builder set --module CrushedEchoTrail --network crushed_echo_trail --agent
hise-cli dsp add --module CrushedEchoTrail --type template.feedback_delay --id EchoLoop --agent
hise-cli dsp add --module CrushedEchoTrail --type fx.bitcrush --id EchoCrusher --parent EchoLoop --agent
hise-cli dsp add --module CrushedEchoTrail --type filters.one_pole --id FeedbackTone --parent EchoLoop --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoCrusher --index 1 --agent
hise-cli dsp set --module CrushedEchoTrail --node FeedbackTone --index 2 --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoCrusher --param Mode --value 1 --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoCrusher --param BitDepth --range "4,12" --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoCrusher --param BitDepth --value 7 --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoLoop_fb_out --param Feedback --range "0,0.8" --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoLoop_fb_out --param Feedback --value 0.45 --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoLoop_delay --param DelayTime --range "80,600" --agent
hise-cli dsp set --module CrushedEchoTrail --node EchoLoop_delay --param DelayTime --value 240 --agent
hise-cli dsp create_parameter --module CrushedEchoTrail --container crushed_echo_trail --id Bits --range "4,12" --default 7 --agent
hise-cli dsp create_parameter --module CrushedEchoTrail --container crushed_echo_trail --id Feedback --range "0,0.8" --default 0.45 --agent
hise-cli dsp create_parameter --module CrushedEchoTrail --container crushed_echo_trail --id DelayMs --range "80,600" --default 240 --agent
hise-cli dsp connect --module CrushedEchoTrail --source crushed_echo_trail --source-param Bits --target EchoCrusher --param BitDepth --matched --agent
hise-cli dsp connect --module CrushedEchoTrail --source crushed_echo_trail --source-param Feedback --target EchoLoop_fb_out --param Feedback --matched --agent
hise-cli dsp connect --module CrushedEchoTrail --source crushed_echo_trail --source-param DelayMs --target EchoLoop_delay --param DelayTime --matched --agent
```

## Key rules

- Keep Bipolar mode in a feedback path to avoid accumulating a DC bias.
- Keep feedback below unity. The template supplies the safe feedback routing and fixed-block timing.
