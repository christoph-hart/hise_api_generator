---
id: math.expr.programmable-scalar-transform
node: math.expr
domain: scriptnode
category: dsp-network
title: Programmable scalar transform
summary: Uses math.expr to compile a one-line SNEX clip formula controlled by a public root parameter.
useCase: Use this when a simple custom per-sample formula is clearer than wiring multiple built-in math nodes.
difficulty: intermediate
networkName: programmable_scalar_transform
moduleType: ScriptFX
moduleId: ProgrammableScalarTransform
tags:
  - expression
  - snex
  - clipper
  - programmable
aliases:
  - expression shaper
  - SNEX formula node
relatedNodes:
  - math.expr
  - math.add
  - analyse.specs
  - math.clear
parameters:
  ClipWidth: Public root parameter matched to ShapeExpr.Value.
  ShapeExpr.Code: One-line SNEX ternary clip expression.
---

scriptnode example: math.expr

Programmable scalar transform.
Use this to demonstrate a simple custom SNEX expression with a matched public parameter.

Graph:
```text
programmable_scalar_transform
  SeedValue             math.add
  InputSpecs            analyse.specs
  ShapeExpr             math.expr
  OutputSpecs           analyse.specs
  SignalClear           math.clear
```

Host:
  Module: `ProgrammableScalarTransform`
  Type: `ScriptFX`
  Network: `programmable_scalar_transform`
  Routing: default stereo
  Builder setup: `add ScriptFX as "ProgrammableScalarTransform"`, then set its network to `programmable_scalar_transform`.

Support nodes:
  Required: `math.add`, `analyse.specs`, `math.clear`

Key rules:
  - `math.expr` requires compilation enabled; the CLI Code write / status autofix handles the network flag.
  - Keep the expression one line and use explicit `f` float suffixes where needed.
  - The public `ClipWidth` parameter is matched to the expression node's `Value` argument.

Public controls:
  - `ClipWidth` -> `ShapeExpr.Value`, matched, range `0.2..0.8`, default `0.4`

HISE CLI build commands:
```bash
hise-cli -hise "playground open" --agent
hise-cli builder reset --agent
hise-cli builder add --type ScriptFX --id ProgrammableScalarTransform --agent
hise-cli builder set --module ProgrammableScalarTransform --network programmable_scalar_transform --agent
hise-cli dsp add --module ProgrammableScalarTransform --type math.add --id SeedValue --agent
hise-cli dsp set --module ProgrammableScalarTransform --node SeedValue --param Value --value 0.5 --agent
hise-cli dsp add --module ProgrammableScalarTransform --type analyse.specs --id InputSpecs --agent
hise-cli dsp add --module ProgrammableScalarTransform --type math.expr --id ShapeExpr --agent
hise-cli dsp set --module ProgrammableScalarTransform --node ShapeExpr --param Value --range "0.2,0.8" --agent
hise-cli dsp set --module ProgrammableScalarTransform --node ShapeExpr --param Value --value 0.4 --agent
hise-cli dsp set --module ProgrammableScalarTransform --node ShapeExpr --param Code --value "input > value ? value : (input < -1.0f * value ? -1.0f * value : input)" --agent
hise-cli dsp add --module ProgrammableScalarTransform --type analyse.specs --id OutputSpecs --agent
hise-cli dsp add --module ProgrammableScalarTransform --type math.clear --id SignalClear --agent
hise-cli dsp create_parameter --module ProgrammableScalarTransform --container programmable_scalar_transform --id ClipWidth --range "0.2,0.8" --default 0.4 --agent
hise-cli dsp connect --module ProgrammableScalarTransform --source programmable_scalar_transform --source-param ClipWidth --target ShapeExpr --param Value --matched --agent
```
