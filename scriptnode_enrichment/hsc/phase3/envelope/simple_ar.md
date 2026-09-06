# envelope.simple_ar - HSC Construction Artifact

## Source
- Phase 2: `scriptnode_enrichment/hsc/phase2/envelope/simple_ar.md`
- Reference: `scriptnode_enrichment/output/envelope/simple_ar.md`

## Status
- Built in HISE: true
- User approved: true
- Notes: Live HISE build completed successfully in a monophonic ScriptFX.

## Naming
- Module ID: `TimerGatedArModulator`
- Network ID: `timer_gated_ar_modulator`

## Builder Setup Applied
- Host context: `Script FX`
- Additional builder steps applied: used the corrected `container.modchain` factory and `control.timer.Interval` parameter.
- Channel/routing setup verified: default stereo routing.

## Verified Parameters
- `PulseTimer.Interval` = `500`, range `[125, 2000]`
- `ArEnvelope.Attack` = `10`, range `[1, 150]`
- `ArEnvelope.Release` = `120`, range `[20, 400]`
- `ArEnvelope.AttackCurve` = `0`

## Verified Connections
- `PulseTimer -> ArEnvelope.Gate`
- `timer_gated_ar_modulator.Attack -> ArEnvelope.Attack` matched
- `timer_gated_ar_modulator.Release -> ArEnvelope.Release` matched
- `timer_gated_ar_modulator.AttackCurve -> ArEnvelope.AttackCurve` matched
- `timer_gated_ar_modulator.PulseRate -> PulseTimer.Interval` matched
- `ArEnvelope -> ModTarget.Gain`

## Optimized Public Shell Commands

```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id TimerGatedArModulator --agent
hise-cli builder set --module TimerGatedArModulator --network timer_gated_ar_modulator --agent
hise-cli dsp add --module TimerGatedArModulator --type container.modchain --id InternalModHost --agent
hise-cli dsp add --module TimerGatedArModulator --type control.timer --id PulseTimer --parent InternalModHost --agent
hise-cli dsp set --module TimerGatedArModulator --node PulseTimer --param Interval --range "125,2000" --agent
hise-cli dsp set --module TimerGatedArModulator --node PulseTimer --param Interval --value 500 --agent
hise-cli dsp add --module TimerGatedArModulator --type math.fill1 --id EnvelopeSeed --parent InternalModHost --agent
hise-cli dsp add --module TimerGatedArModulator --type envelope.simple_ar --id ArEnvelope --parent InternalModHost --agent
hise-cli dsp add --module TimerGatedArModulator --type core.gain --id ModTarget --agent
hise-cli dsp create_parameter --module TimerGatedArModulator --container timer_gated_ar_modulator --id Attack --range "1,150" --default 10 --agent
hise-cli dsp create_parameter --module TimerGatedArModulator --container timer_gated_ar_modulator --id Release --range "20,400" --default 120 --agent
hise-cli dsp create_parameter --module TimerGatedArModulator --container timer_gated_ar_modulator --id AttackCurve --range "0,1" --default 0 --agent
hise-cli dsp create_parameter --module TimerGatedArModulator --container timer_gated_ar_modulator --id PulseRate --range "125,2000" --default 500 --agent
hise-cli dsp connect --module TimerGatedArModulator --source PulseTimer --target ArEnvelope --param Gate --agent
hise-cli dsp connect --module TimerGatedArModulator --source timer_gated_ar_modulator --source-param Attack --target ArEnvelope --param Attack --matched --agent
hise-cli dsp connect --module TimerGatedArModulator --source timer_gated_ar_modulator --source-param Release --target ArEnvelope --param Release --matched --agent
hise-cli dsp connect --module TimerGatedArModulator --source timer_gated_ar_modulator --source-param AttackCurve --target ArEnvelope --param AttackCurve --matched --agent
hise-cli dsp connect --module TimerGatedArModulator --source timer_gated_ar_modulator --source-param PulseRate --target PulseTimer --param Interval --matched --agent
hise-cli dsp connect --module TimerGatedArModulator --source ArEnvelope --target ModTarget --param Gain --agent
```

## Key rules
- Use `container.modchain` and drive `control.timer.Interval`.
- Keep the audible gain target outside the modulation chain.
