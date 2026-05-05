// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

/script
/callback onInit
// end setup
// Context: A standard-looking combo box LAF that draws a rounded rectangle outline,
// left-aligned text, and a dropdown triangle on the right side.

const var comboLaf = Content.createLocalLookAndFeel();

comboLaf.registerFunction("drawComboBox", function(g, obj)
{
    // Draw outline using the component's itemColour1 property
    g.setColour(obj.itemColour1);
    var r = [obj.area[0] + 2, obj.area[1] + 2,
             obj.area[2] - 4, obj.area[3] - 4];
    g.drawRoundedRectangle(r, r[3] / 2.0, 1.0);

    // Draw the selected item text
    g.setColour(Colours.withMultipliedAlpha(obj.textColour, obj.hover ? 1.0 : 0.8));
    g.setFont("Default", 13.0);
    var textArea = [r[0] + 12, r[1], r[2] - r[3] - 12, r[3]];
    g.drawAlignedText(obj.text, textArea, "left");

    // Draw dropdown triangle on the right
    var triPath = Content.createPath();
    triPath.startNewSubPath(0.0, 0.0);
    triPath.lineTo(1.0, 0.0);
    triPath.lineTo(0.5, 1.0);
    triPath.closeSubPath();

    var triArea = [r[0] + r[2] - r[3], r[1], r[3], r[3]];
    triArea = [triArea[0] + 11, triArea[1] + 11,
               triArea[2] - 22, triArea[3] - 22];
    g.fillPath(triPath, triArea);
});

const var cb = Content.addComboBox("StyledCombo", 0, 0);
cb.set("items", "Sine\nSaw\nSquare\nTriangle");
cb.setLocalLookAndFeel(comboLaf);
// test
/compile

# Verify
/expect cb.get("items") is "Sine\nSaw\nSquare\nTriangle"
/exit
// end test
