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
// Title: Complete LAF customization for an audio waveform display
// Context: When building a custom sample player, override all six thumbnail
// draw functions to fully control the waveform's appearance. The
// getThumbnailRenderOptions callback controls how the waveform data is
// processed before drawing.

const var wf = Content.addAudioWaveform("Waveform1", 0, 0);
const var laf = Content.createLocalLookAndFeel();

// Configure rendering before any drawing happens
laf.registerFunction("getThumbnailRenderOptions", function(obj)
{
    obj.forceSymmetry = true;
    obj.manualDownSampleFactor = 1.3;
    obj.scaleVertically = false;
    obj.dynamicOptions = false;
    return obj;
});

// Clear the default background - draw nothing
laf.registerFunction("drawThumbnailBackground", function(g, obj)
{
    // Empty: the waveform sits on a transparent panel background
});

// Draw the waveform shape using the component's fill colour
laf.registerFunction("drawThumbnailPath", function(g, obj)
{
    // obj.area[1] != 0 means this is a secondary channel - skip
    // to render only the first channel for a single-layer display
    if (obj.area[1] != 0)
        return;

    g.setColour(obj.itemColour);
    g.fillPath(obj.path, obj.area);
});

// Draw the playback position as a thin white vertical line
laf.registerFunction("drawThumbnailRuler", function(g, obj)
{
    g.setColour(Colours.white);
    g.fillRect([obj.xPosition, 0, 1, obj.area[3]]);
});

// Suppress default range overlay drawing
laf.registerFunction("drawThumbnailRange", function(g, obj)
{
    // Empty: range selection not used in this display
});

// Suppress default filename text overlay
laf.registerFunction("drawThumbnailText", function(g, obj)
{
    // Empty: filename display handled elsewhere
});

wf.setLocalLookAndFeel(laf);
// test
/compile

# Verify
/expect wf.getWidth() is 200
/exit
// end test
