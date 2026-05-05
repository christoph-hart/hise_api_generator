## loadImage

**Examples:**

```javascript:themed-filmstrip-knob
// Title: Themed filmstrip knob with switchable image aliases
// Context: A plugin with multiple visual themes loads the same filmstrip
// under different aliases, then selects the alias at draw time based on
// the current theme index.

const var knobLaf = Content.createLocalLookAndFeel();

// Load the same (or different) filmstrip images under theme-keyed aliases
knobLaf.loadImage("{PROJECT_FOLDER}Slider_Grey.png", "grey");
knobLaf.loadImage("{PROJECT_FOLDER}Slider_Blue.png", "blue");
knobLaf.loadImage("{PROJECT_FOLDER}Slider_Pink.png", "pink");

const var NUM_FRAMES = 128;
const var FRAME_HEIGHT = 46;

// Theme index (0 = grey, 1 = blue, 2 = pink)
reg currentTheme = 0;

const var themeAliases = ["grey", "blue", "pink"];

knobLaf.registerFunction("drawRotarySlider", function(g, obj)
{
    // Select filmstrip frame from normalized value
    var frameIndex = parseInt(obj.valueNormalized * (NUM_FRAMES - 1));
    var yOffset = frameIndex * FRAME_HEIGHT;

    g.drawImage(themeAliases[currentTheme], obj.area, 0, yOffset);
});

const var knob = Content.addKnob("ThemedKnob", 10, 10);
knob.setLocalLookAndFeel(knobLaf);
```

```json:testMetadata:themed-filmstrip-knob
{
  "testable": false,
  "skipReason": "Requires filmstrip image files in the project Images folder"
}
```


