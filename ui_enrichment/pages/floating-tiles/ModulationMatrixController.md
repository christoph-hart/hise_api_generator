---
title: "ModulationMatrixController"
description: "Companion source-list panel for the matrix modulation system — pick the modulation source whose connections the matrix edits."
contentType: "ModulationMatrixController"
componentType: "floating-tile"
screenshot: "/images/v2/reference/ui-components/floating-tiles/modulationmatrixcontroller.png"
llmRef: |
  ModulationMatrixController (FloatingTile)
  ContentType string: "ModulationMatrixController"
  Set via: FloatingTile.set("ContentType", "ModulationMatrixController")

  Companion to ModulationMatrix. Lists the available modulation sources and lets the user pick which one the matrix grid edits next. Optional UnselectableExclusiveSource flag prevents users from clicking exclusive sources (those owning all current routes).

  JSON Properties:
    ProcessorId: ID of the target module (typically the same as the linked ModulationMatrix)
    UnselectableExclusiveSource: Disable selection of sources whose connections would be exclusive (default: false)

  Customisation:
    LAF: none
    CSS: none
seeAlso: []
commonMistakes:
  - title: "Controller has no effect"
    wrong: "Adding a ModulationMatrixController without a ModulationMatrix on the same page"
    right: "Pair the controller with a ModulationMatrix — the controller selects sources, the matrix renders connections for the selected target"
    explanation: "The controller is purely a source picker. Without a ModulationMatrix listening to the same target it has nothing to drive."
---

![ModulationMatrixController](/images/v2/reference/ui-components/floating-tiles/modulationmatrixcontroller.png)

The ModulationMatrixController floating tile is the companion source list for the [ModulationMatrix]($UI.ModulationMatrix$) editor. It lists all modulation sources currently registered with the matrix system and lets the user pick which one the matrix grid is editing.

Use the two together: place a `ModulationMatrix` next to a `ModulationMatrixController`, point both at the same target (`ProcessorId`), and the user can select a source on the controller to update the connections shown in the matrix.

## Setup

```javascript
const var matrix = Content.getComponent("FloatingTile_Matrix");
const var controller = Content.getComponent("FloatingTile_Controller");

matrix.set("ContentType", "ModulationMatrix");
matrix.set("Data", JSON.stringify({
    "ProcessorId": "Master Chain",
    "MatrixStyle": "TableMatrix",
    "SliderStyle": "Knob"
}));

controller.set("ContentType", "ModulationMatrixController");
controller.set("Data", JSON.stringify({
    "ProcessorId": "Master Chain",
    "UnselectableExclusiveSource": false
}));
```

## JSON Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `ProcessorId` | String | `""` | The ID of the target module (typically the same one used by the paired ModulationMatrix) |
| `Index` | int | `-1` | Reserved (not used by this content type) |
| `UnselectableExclusiveSource` | bool | `false` | When `true`, modulation sources whose connections are flagged as exclusive cannot be selected from the controller |

The `ColourData` object can be used to set colours for the default rendering:

| Colour ID | Description |
|-----------|-------------|
| `bgColour` | Background colour |
| `textColour` | Source label colour |
| `itemColour1` | Selected source highlight colour |
| `itemColour2` | Hover highlight colour |

## Notes

- The controller and matrix share their selection through the project's first `GlobalModulatorContainer`. They do not need to be wired manually as long as both `ProcessorId` properties point at the same target.
- `UnselectableExclusiveSource = true` is useful when a source owns the entire route set for a target and should not be reassigned by the user mid-session. Disabled sources still appear in the list but cannot be selected.
- This content type has no LAF or CSS support — only the colour data drives appearance. For a fully custom source picker, replace the controller with a ScriptedViewport in list mode populated from the `MatrixHandler` scripting API.
- The matrix modulation system is a HISE 5.0+ feature. Add a `Global Modulator Container` at the top of the modulator chain to enable it.

**See also:** $UI.ModulationMatrix$ -- the matrix editor this controller drives, $MODULES.GlobalModulatorContainer$ -- container that stores the matrix connections, $API.ScriptFloatingTile$ -- scripting API for the floating tile wrapper
