## withHue

**Examples:**


```javascript:random-colour
// Title: Random colour generation with controlled saturation/brightness
// Context: Creating randomized colours for visual variety (e.g., preset
// tags, user categories) while keeping them visually cohesive by fixing
// saturation and brightness.

inline function getRandomColour()
{
    local c = Colours.withHue(Colours.red, Math.random());
    c = Colours.withSaturation(c, 0.5);
    c = Colours.withBrightness(c, 0.4);
    return c;
}

var c1 = getRandomColour();
var c2 = getRandomColour();
Console.print("Colour 1: " + c1);
Console.print("Colour 2: " + c2);
```
```json:testMetadata:random-colour
{
  "testable": false,
  "skipReason": "Non-deterministic Math.random()"
}
```

**Cross References:**
- `Colours.withSaturation`
- `Colours.withBrightness`
