# Constraint Normalization Guide

This guide defines how natural-language parameter constraints from `constraints.json` are converted into diagnostic checks for the HiseScript shadow parser.

The goal is **actionable, parser-stage validation**, not a complete restatement of the documentation. Preserve only constraints that can produce a reliable diagnostic or explicitly mark a parameter for a custom diagnostic implementation.

## Output form

A normalized constraint is a string consisting of a check type followed by an optional argument:

```text
CheckType.argument
```

Arguments that contain structured data use valid JSON:

```text
RangeCheck.{"min":0,"max":127,"inclusive":true,"clamps":false}
```

If a parameter needs more than one independent check, the normalized representation may contain multiple check entries.

## General rules

1. **Prefer deterministic checks.** Emit a check only when the source constraint gives enough information for a reliable parser diagnostic or clearly identifies a custom check.
2. **Use method and parameter context.** Short constraints such as `1 argument`, `valid property ID`, or `range depends on the parameter` cannot be interpreted in isolation.
3. **Scan the relevant C++ method when needed.** Valid option strings are often embedded in the implementation, for example in a `StringArray` or switch statement. The LLM should do a quick source scan rather than inventing values.
4. **Use public/runtime concepts rather than internal C++ implementation types.** For example, normalize `ProcessorFilterStatistics::Holder` to `CurveEq`.
5. **Do not infer checks from generic prose.** Skip behavioral descriptions, implementation details, internal sanitation, defaults, optionality, and constraints that require inspecting dynamic values unavailable to the parser.
6. **Custom checks are valid.** `Conditional.<parameterName>` and `$CUSTOM.…$` explicitly identify cases requiring hand-written diagnostic logic.

## Check categories

### Range checks

Use `RangeCheck` for numeric lower bounds, upper bounds, or intervals:

```text
RangeCheck.{"min":0,"inclusive":true}
RangeCheck.{"max":127,"inclusive":true}
RangeCheck.{"min":0.0,"max":1.0,"inclusive":true,"clamps":true}
```

- `inclusive: true` means the endpoints are valid (`>=` / `<=`).
- `inclusive: false` means the endpoints are excluded (`>` / `<`).
- Omit `min` or `max` for one-sided ranges.
- Use `clamps: true` when the runtime accepts an out-of-range value but clamps it. Diagnostics should emit a hint or warning, not an error.
- Use `clamps: false` when the source explicitly says that no range validation or clamping is performed.
- A symbolic preprocessor bound uses `$PP.NAME$`:

```text
RangeCheck.{"min":0,"max":"$PP.MAX_SCRIPT_HEIGHT$","inclusive":true}
```

- A bound requiring a custom runtime expression uses `$CUSTOM.…$`:

```text
RangeCheck.{"min":0,"max":"$CUSTOM.getNumAttributes() - 1$","inclusive":true}
```

### Callback checks

Use `CallbackArgCheck` when a parameter receives a callback. The basic form records arity and callback requirements:

```text
CallbackArgCheck.2.Inline
CallbackArgCheck.3.Realtime
CallbackArgCheck.1.Function
```

When the callback's argument types are known, use the typed form:

```text
CallbackArgCheck.Function(Graphics)
CallbackArgCheck.Inline(ScriptSlider, double)
```

The typed form contains the callback mode followed by the callback argument types in order. It is preferred when the C++ source or established API semantics provide the types. `ScriptPanel.setPaintRoutine` always receives a `Graphics` object, while `ScriptSlider.setControlCallback` receives `(ScriptSlider, double)` even though the original constraint only states the callback arity.

Modes established so far:

- `Function`: callback/function required; use only when the arity is known.
- `Inline`: callback must be an inline function.
- `Realtime`: callback must be realtime-capable.

Do not infer arity, argument types, or realtime/inline requirements from `Must be a function` alone. A vague callback constraint requires a C++ source scan when the method or parameter is an obvious callback candidate.

#### Callback hardening rule

Callback-looking parameters must not silently pass through without a callback check. Treat a parameter as an obvious callback candidate when either:

- the method name contains `Callback` (for example, `setServerCallback`), or
- the parameter name is callback-like, such as `callback`, `function`, `callbackFunction`, `handler`, or another clearly equivalent name.

Every obvious callback candidate must resolve to the appropriate `CallbackArgCheck` type. First use explicit arity, inline, and realtime information from the constraint text. If the constraint is underspecified, scan the C++ declaration and implementation to determine the callback signature and requirements. If the source still does not provide enough information, mark the parameter for a diagnostic follow-up rather than treating it as an ordinary function parameter.

Examples:

```text
CallbackArgCheck.2.Inline
CallbackArgCheck.3.Realtime
CallbackArgCheck.1.Function
```

This rule is stronger than the general disregard rule: `Must be a function` may be insufficient to construct the final check, but it is a signal that source lookup is required for an obvious callback candidate.

### Runtime ID checks

Use `RuntimeIdCheck.<target>` when a value must resolve against a runtime-owned collection or object:

```text
RuntimeIdCheck.DspNetwork
RuntimeIdCheck.ScriptComponent
RuntimeIdCheck.ScriptComponentProperty
RuntimeIdCheck.CurveEq
RuntimeIdCheck.ExternalDataHolder
RuntimeIdCheck.Expansions
RuntimeIdCheck.Modulator
```

Internal C++ class names should be reduced to the runtime concept used by the script API. Manual mappings are appropriate when the target concept depends on HISE-specific knowledge.

### Object type checks

Use `ObjectType.<type>` when the object type is statically checkable:

```text
ObjectType.File
ObjectType.JSON
ObjectType.Array
```

Do not attempt to validate the types of dynamically resolved array elements at parser stage. A constraint that requires an array may still produce `ObjectType.Array` even when its element-level requirements are skipped.

### String validators

Use `StringValidator.ValidVariableId` for identifiers accepted by Content creation methods, including `Content.addXXX()` methods:

```text
StringValidator.ValidVariableId
```

Use `StringValidator.Option[...]` for a finite set of string options. The values must be confirmed from the source when the enrichment text does not list them:

```text
StringValidator.Option["Back","Default","Front","AlwaysOnTop"]
```

### Graphics checks

Use dedicated graphics checks for common HISE graphics argument conventions:

```text
GraphicsCheck.Area
GraphicsCheck.Point
GraphicsCheck.ValidColour
```

- `GraphicsCheck.Area` accepts a `Rectangle` object or a four-element array representing a rectangle.
- `GraphicsCheck.Point` accepts the graphics API's point representation, established here as a two-element array.
- `GraphicsCheck.ValidColour` accepts the colour representations supported by the graphics/colour API, such as ARGB integers, hexadecimal strings, or named constants.

### Conditional checks

Use `Conditional.<parameterName>` when one parameter's validity depends on another parameter, or when the relationship is obvious but the actual validation requires custom logic:

```text
Conditional.type
Conditional.propertyId
Conditional.yOffset
Conditional.chainIndex
Conditional.attributeIndex
```

The suffix identifies the controlling parameter. For example, the `value` argument in `setStyleSheetProperty(value)` depends on `type`, while `newValue` in `ScriptButton.set(propertyId, newValue)` depends on `propertyId`.

This is also a generic escape hatch for context-sensitive checks such as looking up modulation chains or attribute definitions in the target module.

## Disregard categories

Do not emit diagnostic checks for:

- `--`, `—`, or other placeholders.
- Optional parameters or default values; these are already handled by diagnostics.
- Primitive types such as Boolean, Number, String, or “Any type”; existing type validation handles them.
- Behavioral descriptions, such as “0 for immediate”, “alpha controls opacity”, or “supports `*` glob wildcard”.
- Internal sanitation, including NaN/Inf handling.
- Requirements that need dynamic array element inspection.
- Requirements that depend on complex memory layouts or fringe APIs.
- File-path existence checks when only the static `File` object type is useful.
- Generic structural requirements that cannot be reliably checked at parser stage.

## Worked examples

The following examples are taken from the reviewed enrichment data and show the intended real-world normalization.

### Runtime IDs and object types

| API parameter | Source constraint | Normalized check |
|---|---|---|
| `Engine.getDspNetworkReference(id)` | Must be a valid network ID registered on the target processor. | `RuntimeIdCheck.DspNetwork` |
| `Broadcaster.addComponentValueListener(object)` | Must resolve to valid ScriptComponent(s). | `RuntimeIdCheck.ScriptComponent` |
| `Broadcaster.attachToEqEvents(moduleIds)` | Each must resolve to a processor implementing `ProcessorFilterStatistics::Holder`. | `RuntimeIdCheck.CurveEq` |
| `Broadcaster.attachToComplexData(moduleIds)` | Each must resolve to a processor that implements `ExternalDataHolder`. | `RuntimeIdCheck.ExternalDataHolder` |
| `Content.getComponent(componentName)` | Must match a created component. | `RuntimeIdCheck.ScriptComponent` |
| `ScriptButton.get(propertyName)` | Must be a valid property ID for this component type. | `RuntimeIdCheck.ScriptComponentProperty` |
| `ExpansionHandler.getExpansion(name)` | Matched against the expansion's `Name` property. | `RuntimeIdCheck.Expansions` |
| `Modulator.addGlobalModulator(modName)` | Should be unique within the module tree. | `RuntimeIdCheck.Modulator` |
| `Settings.setSampleFolder(sampleFolder)` | Must be a `File` object pointing to an existing directory. | `ObjectType.File` (discard the directory-existence part) |
| `ExpansionHandler.getExpansionForInstallPackage(packageFile)` | Must be a `File` object; non-File triggers script error. | `ObjectType.File` |
| `MidiPlayer.flushMessageListToSequence(messageList)` | Each element must be a `MessageHolder`. | `ObjectType.Array` (discard element inspection) |
| `WavetableController.setPostFXProcessors(postFXData)` | Each element must be a JSON object with a `Type` property. | `ObjectType.JSON` |
| `NeuralNetwork.build(modelJSON)` | Must be a valid layer array. | `ObjectType.JSON` |

### Ranges

| API parameter | Source constraint | Normalized check |
|---|---|---|
| `ScriptTable.setTablePoint(curve)` | Clamped to 0.0–1.0. | `RangeCheck.{"min":0.0,"max":1.0,"inclusive":true,"clamps":true}` |
| `ScriptTable.setTablePoint(y)` | Clamped to 0.0–1.0. | `RangeCheck.{"min":0.0,"max":1.0,"inclusive":true,"clamps":true}` |
| `Table.setTablePoint(curve)` | 0.0–1.0. | `RangeCheck.{"min":0.0,"max":1.0,"inclusive":true}` |
| `ScriptedViewport.setPosition(y)` | 0–`MAX_SCRIPT_HEIGHT`. | `RangeCheck.{"min":0,"max":"$PP.MAX_SCRIPT_HEIGHT$","inclusive":true}` |
| `SliderPackData.setUsePreallocatedLength(length)` | >= 0. | `RangeCheck.{"min":0,"inclusive":true}` |
| `SliderPackData.setRange(stepSize)` | > 0. | `RangeCheck.{"min":0,"inclusive":false}` |
| `Math.log10(value)` | > 0.0. | `RangeCheck.{"min":0.0,"inclusive":false}` |
| `Math.acosh(value)` | >= 1.0. | `RangeCheck.{"min":1.0,"inclusive":true}` |
| `Engine.setLowestKeyToDisplay(keyNumber)` | 0–127; no range validation is performed. | `RangeCheck.{"min":0,"max":127,"inclusive":true,"clamps":false}` |
| `Synth.playNoteWithStartOffset(offset)` | 0–65535. | `RangeCheck.{"min":0,"max":65535,"inclusive":true}` |
| `Engine.getSamplesForQuarterBeats(quarterBeats)` | Any positive number. | `RangeCheck.{"min":0,"inclusive":false}` |
| `Engine.getQuarterBeatsForMilliSeconds(milliSeconds)` | Any positive number. | `RangeCheck.{"min":0,"inclusive":false}` |
| `Colours.withMultipliedBrightness(factor)` | >= 0.0; no upper bound; result clamped internally. | `RangeCheck.{"min":0.0,"inclusive":true,"clamps":true}` |
| `Buffer.getMagnitude(numSamples)` | Clamped to available range. | `RangeCheck.{"clamps":true}` (dynamic upper bound requires custom resolution) |
| `Engine.getGainFactorForDecibels(decibels)` | Values at or below -100 dB return 0.0. | `RangeCheck` threshold requiring method-context interpretation |
| `Synth.addEffect(index)` | -1 to append, or 0-based index. | Disregard as behavioral/overloaded semantics |
| `Sampler.setSoundProperty(soundIndex)` | 0 to `getNumSelectedSounds()-1`. | `RangeCheck.{"min":0,"max":"$CUSTOM.getNumSelectedSounds() - 1$","inclusive":true}` |
| `MidiProcessor.getAttributeId(parameterIndex)` | 0 to `getNumAttributes()-1`. | `RangeCheck.{"min":0,"max":"$CUSTOM.getNumAttributes() - 1$","inclusive":true}` |

### Callbacks

| API parameter | Source constraint | Normalized check |
|---|---|---|
| `FFT.setPhaseFunction(newPhaseFunction)` | Must be an inline function with 2 parameters. | `CallbackArgCheck.2.Inline` |
| `ScriptSlider.setControlCallback(controlFunction)` | Must be inline and take exactly 2 parameters. | `CallbackArgCheck.2.Inline` |
| `SliderPackData.setContentCallback(contentFunction)` | 1 argument. | `CallbackArgCheck.1.Function` |
| `ExpansionHandler.setExpansionCallback(expansionLoadedCallback)` | Must be a function. | Disregard arity/realtime is unspecified |

### Conditional and specialized checks

| API parameter | Source constraint | Normalized check |
|---|---|---|
| `ScriptPanel.setStyleSheetProperty(value)` | Type must match the conversion specified by the `type` parameter. | `Conditional.type` |
| `ScriptButton.set(propertyId, newValue)` | Value depends on the selected property ID. | `Conditional.propertyId` |
| `ScriptPanel.setImage(xOffset)` | One of `xOffset` or `yOffset` must be 0. | `Conditional.yOffset` |
| `ChildSynth.addStaticGlobalModulator(chainIndex)` | Must be a valid ModulatorChain index. | `Conditional.chainIndex` |
| `Synth.setAttribute(newAttribute)` | Range depends on the specific parameter. | `Conditional.attributeIndex` (use the actual controlling parameter name from the method) |
| `NeuralNetwork.process(input)` | Number, Array, or Buffer matching model input size. | Disregard dynamic shape/size validation |
| `Engine.isControllerUsedByAutomation(controllerNumber)` | Array form contains MIDI channel and CC number ranges. | Disregard; array lookup is required |

### String and graphics validation

| API parameter | Source constraint | Normalized check |
|---|---|---|
| `Content.addButton(buttonName)` | No whitespace. | `StringValidator.ValidVariableId` |
| Other `Content.addXXX()` names | Identifier must be valid for a Content component name. | `StringValidator.ValidVariableId` |
| `ScriptLabel.setZLevel(zLevel)` | One of four valid values; source lists `Back`, `Default`, `Front`, `AlwaysOnTop`. | `StringValidator.Option["Back","Default","Front","AlwaysOnTop"]` |
| `Colours.mix(colour1)` | ARGB integer, hex string, or named constant. | `GraphicsCheck.ValidColour` |
| `Path.addEllipse(area)` | 4-element array or Rectangle object. | `GraphicsCheck.Area` |
| `Graphics.drawAlignedText(area)` | Area parameter in a graphics API. | `GraphicsCheck.Area` |
| `DisplayBuffer.createPath(dstArea)` | 4-element array parseable as rectangle. | `GraphicsCheck.Area` |
| `Path.addPolygon(center)` | 2-element array. | `GraphicsCheck.Point` |

## Examples intentionally omitted

The following kinds of reviewed entries were intentionally not normalized: placeholders, defaults, optional parameters, primitive Boolean/Number/Any-type descriptions, behavioral notes, NaN/Inf sanitation, wildcard matching, file/key-file fringe behavior, memory-layout matching, dynamic array element schemas, and internal C++ implementation details that do not map to a parser-stage check.
