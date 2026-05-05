## toVec4

**Examples:**

```javascript:glsl-uniform
// Title: Passing a colour to a GLSL shader as a vec4 uniform
// Context: When using ScriptShader for GPU-rendered visuals, shader
// uniforms expect float arrays. toVec4 converts an ARGB integer
// colour into the [r, g, b, a] float format that GLSL vec4 requires.

const var panel = Content.addPanel("ShaderPanel", 0, 0);
panel.set("width", 400);
panel.set("height", 400);

const var shader = Content.createShader("myShader");

// Convert a theme colour and pass it to the shader
var accentColour = Colours.withAlpha(0xFF94F2FF, 0.8);
shader.setUniformData("uColour", Colours.toVec4(accentColour));

// The shader receives it as: uniform vec4 uColour; // [r, g, b, a] in 0.0-1.0
```
```json:testMetadata:glsl-uniform
{
  "testable": false,
  "skipReason": "Requires ScriptShader context"
}
```


