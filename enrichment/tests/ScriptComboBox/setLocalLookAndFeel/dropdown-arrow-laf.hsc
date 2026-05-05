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
// Title: Minimal dropdown-arrow combo box with custom popup menu
// Context: A common pattern for selectors that show only a small dropdown arrow and
// custom-styled popup items. The drawComboBox callback renders just the triangle indicator,
// while separate popup menu functions style the dropdown list.

const var selectorLaf = Content.createLocalLookAndFeel();

selectorLaf.registerFunction("drawComboBox", function(g, obj)
{
    g.setColour(obj.hover ? 0xBBFFFFFF : 0x88FFFFFF);

    // Position the triangle in the right portion of the area
    var triArea = [obj.area[0] + obj.area[2] - obj.area[3],
                   obj.area[1], obj.area[3], obj.area[3]];

    // Shrink and draw a downward-pointing triangle
    triArea = [triArea[0] + 10, triArea[1] + 10,
               triArea[2] - 20, triArea[3] - 20];
    g.fillTriangle(triArea, Math.PI);
});

// Style the popup menu to match
selectorLaf.registerFunction("drawPopupMenuBackground", function(g, obj)
{
    g.fillAll(0xFF222222);
});

selectorLaf.registerFunction("drawPopupMenuItem", function(g, obj)
{
    if (obj.isHighlighted)
    {
        g.setColour(0x22FFFFFF);
        g.fillRect(obj.area);
    }

    g.setColour(obj.isTicked ? Colours.white : 0xAAFFFFFF);
    g.setFont("Default", 13.0);

    var textArea = obj.area.clone();
    textArea[0] += 10;
    g.drawAlignedText(obj.text, textArea, "left");
});

const var cbSelector = Content.addComboBox("Selector", 0, 0);
cbSelector.set("items", "Option A\nOption B\nOption C");
cbSelector.setLocalLookAndFeel(selectorLaf);
// test
/compile

# Verify
/expect cbSelector.get("items") is "Option A\nOption B\nOption C"
/exit
// end test
