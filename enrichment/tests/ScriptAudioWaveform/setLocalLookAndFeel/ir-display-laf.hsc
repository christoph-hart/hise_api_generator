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
// Context: For impulse response displays, scaleVertically normalizes the
// visual amplitude so quiet IRs are still clearly visible. A custom
// background draws placeholder text when no IR is loaded.

const var irWaveform = Content.addAudioWaveform("IRWaveform1", 0, 0);
const var irLaf = Content.createLocalLookAndFeel();

irLaf.registerFunction("getThumbnailRenderOptions", function(obj)
{
    obj.manualDownSampleFactor = 2.0;
    obj.scaleVertically = true;
    obj.forceSymmetry = false;
    obj.dynamicOptions = false;
    return obj;
});

irLaf.registerFunction("drawThumbnailBackground", function(g, obj)
{
    if (obj.area[1] != 0)
        return;

    g.fillAll(0xFF2A2A2A);

    // Show placeholder text when the area is small (no data loaded)
    if (obj.area[3] < 50)
    {
        g.setColour(0x59FFFFFF);
        g.drawAlignedText("No IR loaded", obj.area, "centred");
    }
});

irLaf.registerFunction("drawThumbnailPath", function(g, obj)
{
    if (obj.area[1] != 0)
        return;

    // Double the vertical area for a top-half-only display
    obj.area[3] *= 2;

    g.setColour(obj.textColour);
    g.fillPath(obj.path, obj.area);
});

// Suppress ruler, range, and text for IR displays
irLaf.registerFunction("drawThumbnailRuler", function(g, obj) {});
irLaf.registerFunction("drawThumbnailRange", function(g, obj) {});
irLaf.registerFunction("drawThumbnailText", function(g, obj) {});

irWaveform.setLocalLookAndFeel(irLaf);
// test
/compile

# Verify
/expect irWaveform.getWidth() is 200
/exit
// end test
