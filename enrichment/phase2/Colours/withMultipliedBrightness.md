## withMultipliedBrightness

**Examples:**


```javascript:hover-brighten
// Title: Hover highlighting by boosting brightness
// Context: An alternative hover technique to Colours.mix -- multiply
// brightness above 1.0 when hovered to brighten the colour in-place.
// Works well for saturated accent colours where mixing with white
// would desaturate.

const var laf = Content.createLocalLookAndFeel();

laf.registerFunction("drawRotarySlider", function(g, obj)
{
    // Factor > 1.0 brightens on hover; 1.0 leaves unchanged
    var c = Colours.withMultipliedBrightness(obj.itemColour1, obj.hover ? 1.4 : 1.0);
    g.setColour(c);
    g.fillEllipse(Rect.reduced(obj.area, 4.0));
});
```
```json:testMetadata:hover-brighten
{
  "testable": false,
  "skipReason": "LAF paint callback requires UI render context"
}
```
