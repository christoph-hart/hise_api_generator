ScriptImage::set(String propertyName, NotUndefined value) -> undefined

Thread safety: UNSAFE
Sets a component property to the given value. Reports a script error if the
property does not exist. During onInit, changes apply without UI notification;
outside onInit, sends change notifications to update the UI.

| Property | Description |
|----------|-------------|
| `x`, `y`, `width`, `height` | Position and size in pixels, relative to parent |
| `visible`, `enabled`, `locked` | Display and interaction state |
| `tooltip` | Hover tooltip (`text` is deactivated) |
| *`Alpha`*, *`Offset`*, *`Scale`* | Image opacity, offset, and scaling |
| *`FileName`*, *`BlendMode`* | Source image file and blend mode |
| *`AllowCallbacks`* | Mouse callback level for image interaction |
| *`PopupMenuItems`*, *`PopupOnRightClick`* | Popup menu content and trigger mode |
| `parentComponent` | Parent component for layout nesting |
| `saveInPreset`, `useUndoManager`, `deferControlCallback` | Preset persistence, undo, and callback deferral |
| `isPluginParameter`, `pluginParameterName`, `pluginParameterGroup`, `isMetaParameter` | Automation and meta-parameter support (`automationId` is deactivated) |
| `processorId`, `parameterId` | Module parameter connection |

Deactivated properties: `bgColour`, `itemColour`, `itemColour2`, `min`, `max`, `defaultValue`, `textColour`, `macroControl`, `automationId`, `linkedTo`, `text`.
Pair with:
  get -- reads the property value
  getAllProperties -- lists all valid property IDs
  setImageFile -- convenience alternative for set("fileName", path)
  setAlpha -- convenience alternative for set("alpha", value)
Anti-patterns:
  - Do NOT pass an invalid property name -- triggers a script error
Source:
  ScriptingApiContent.cpp  ScriptComponent::set()
    -> setScriptObjectPropertyWithChangeMessage(id, value)
    -> for FileName: calls setImageFile() to load image
    -> for BlendMode: looks up gin::BlendMode and calls updateBlendMode()
