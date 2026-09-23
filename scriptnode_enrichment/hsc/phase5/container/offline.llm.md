---
id: container.offline.event-driven-control-pipeline
node: container.offline
domain: scriptnode
category: dsp-network
title: "Event-Driven Control Pipeline"
summary: "A container for offline processing that skips the realtime audio callback."
useCase: "Demonstrate the distinction between skipped realtime processing callbacks and synchronous parameter updates for control-only children inside `container.offline`."
difficulty: intermediate
networkName: event_driven_control_pipeline
moduleType: ScriptFX
moduleId: EventDrivenControlPipeline
tags:
  - container
  - offline
aliases:
  - event-driven control pipeline
  - offline container
relatedNodes:
  - container.offline
  - control.cable_expr
  - control.pma
  - math.mul
parameters:
  Amount: "Amount -> AmountCurve.Value matched"
  Target: "Target range before connection: [0, 1]"
  Macro: "Macro range: [0, 1]"
  Default:: "Default: 0.5"
---

scriptnode example: container.offline

Event-Driven Control Pipeline.

Demonstrate the distinction between skipped realtime processing callbacks and synchronous parameter updates for control-only children inside `container.offline`.

Graph:
```text
event_driven_control_pipeline
  OfflineControls        container.offline
    AmountCurve          control.cable_expr
    GainRange            control.pma
  AudioGain              math.mul
```

Host:
  Module: EventDrivenControlPipeline
  Network: event_driven_control_pipeline
  Type: `ScriptFX`
  Builder setup: `add ScriptFX as "EventDrivenControlPipeline"`, then set its network to `event_driven_control_pipeline`.

Support nodes:
  Required: control.cable_expr, control.pma, math.mul
  `control.cable_expr` applies a quadratic response whenever Amount changes; `control.pma` scales that result into a safe non-zero gain interval and clamps it to 0 to 1; and `math.mul`, placed outside the offline container in the audio path, proves that the transformed value still reaches a realtime processor.

Key rules:

Public controls:
  - Amount -> AmountCurve.Value matched
  - Target range before connection: [0, 1]
  - Macro range: [0, 1]
  - Default: 0.5

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id EventDrivenControlPipeline --agent
hise-cli builder set --module EventDrivenControlPipeline --network event_driven_control_pipeline --agent

# Children receive preparation and reset, but no realtime process, frame, or MIDI callbacks.
hise-cli dsp add --module EventDrivenControlPipeline --type container.offline --id OfflineControls --agent
hise-cli dsp add --module EventDrivenControlPipeline --type control.cable_expr --id AmountCurve --parent OfflineControls --agent
hise-cli dsp add --module EventDrivenControlPipeline --type control.pma --id GainRange --parent OfflineControls --agent
# Keep the sample processor outside the offline container.
hise-cli dsp add --module EventDrivenControlPipeline --type math.mul --id AudioGain --agent

hise-cli dsp set --module EventDrivenControlPipeline --node AmountCurve --param Code --value '"input * input"' --agent
hise-cli dsp set --module EventDrivenControlPipeline --node GainRange --param Multiply --value 0.8 --agent
hise-cli dsp set --module EventDrivenControlPipeline --node GainRange --param Add --value 0.2 --agent
hise-cli dsp set --module EventDrivenControlPipeline --node AudioGain --param Value --range "0,1" --stepSize 0 --agent

hise-cli dsp create_parameter --module EventDrivenControlPipeline --container event_driven_control_pipeline --id Amount --range "0,1" --default 0.5 --agent
hise-cli dsp connect --module EventDrivenControlPipeline --source event_driven_control_pipeline --source-param Amount --target AmountCurve --param Value --matched --agent
hise-cli dsp connect --module EventDrivenControlPipeline --source AmountCurve --target GainRange --param Value --agent
hise-cli dsp connect --module EventDrivenControlPipeline --source GainRange --target AudioGain --param Value --agent

# cable_expr requires a compile-enabled network. Apply and verify HISE's status autofix if needed.
hise-cli dsp status --module EventDrivenControlPipeline --autofix --agent
hise-cli dsp status --module EventDrivenControlPipeline --agent

hise-cli dsp set --module EventDrivenControlPipeline --node OfflineControls --param NodeColour --value 0xFF7F8C8D --agent
hise-cli dsp set --module EventDrivenControlPipeline --node OfflineControls --param Comment --value '"Children are prepared and reset but receive no realtime process, frame, or MIDI callbacks. Audio passes through unchanged."' --agent
hise-cli dsp set --module EventDrivenControlPipeline --node AmountCurve --param NodeColour --value 0xFF687273 --agent
hise-cli dsp set --module EventDrivenControlPipeline --node AmountCurve --param Comment --value '"SNEX squares Amount. This cable node propagates parameter changes synchronously without realtime processing."' --agent
hise-cli dsp set --module EventDrivenControlPipeline --node GainRange --param NodeColour --value 0xFF687273 --agent
hise-cli dsp set --module EventDrivenControlPipeline --node GainRange --param Comment --value '"Maps the squared control to 0.2..1.0 and immediately forwards it to AudioGain."' --agent
hise-cli dsp set --module EventDrivenControlPipeline --node AudioGain --param NodeColour --value 0xFF687273 --agent
hise-cli dsp set --module EventDrivenControlPipeline --node AudioGain --param Comment --value '"The sample processor must remain outside OfflineControls; only its parameter is driven by the offline cable chain."' --agent
```

