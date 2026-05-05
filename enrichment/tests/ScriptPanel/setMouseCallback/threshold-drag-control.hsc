// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: UI scaffold
/ui
add ScriptSlider "ThresholdKnob" at 0 0 128 48
/exit

/script
/callback onInit
// end setup
// Title: Interactive threshold control with drag, double-click reset, and hover feedback
// Context: A display panel where the user drags a vertical line to set a threshold.
// Demonstrates the full mouse event state machine: click sets initial value,
// drag updates continuously, double-click resets to default, hover changes cursor.

const var display = Content.addPanel("ThresholdDisplay", 0, 0);
display.set("width", 300);
display.set("height", 100);
display.set("allowCallbacks", "All Callbacks");

display.data.threshold = 0.5;
display.data.hover = false;
display.data.dragging = false;
display.data.downValue = 0.0;

const var thresholdKnob = Content.getComponent("ThresholdKnob");

display.setMouseCallback(function(event)
{
    this.data.hover = event.hover;

    if (event.clicked)
    {
        // Store starting value for drag offset calculation
        this.data.downValue = event.x / this.getWidth();
        this.data.threshold = this.data.downValue;
        this.data.dragging = true;
    }
    else if (event.doubleClick)
    {
        // Reset to default on double-click
        this.data.threshold = 0.5;
        thresholdKnob.setValue(0.5);
        thresholdKnob.changed();
    }
    else if (event.drag)
    {
        // Continuous update during drag
        local delta = event.dragX / this.getWidth();
        local newValue = Math.range(this.data.downValue + delta, 0.0, 1.0);
        this.data.threshold = newValue;
    }
    else if (event.mouseUp)
    {
        this.data.dragging = false;

        // Commit final value to the connected knob
        thresholdKnob.setValueNormalized(this.data.threshold);
        thresholdKnob.changed();
    }

    this.repaint();
});

display.setPaintRoutine(function(g)
{
    g.fillAll(0xFF27282A);

    // Draw threshold line
    local x = this.data.threshold * this.getWidth();
    local alpha = this.data.hover ? 0.8 : 0.4;
    g.setColour(Colours.withAlpha(this.get("itemColour"), alpha));
    g.fillRect([x, 0, 2, this.getHeight()]);

    // Draw border
    g.setColour(0xFF27282A);
    g.drawRoundedRectangle(this.getLocalBounds(0), 3.0, 2);
});
// test
Console.testCallback(display, "setMouseCallback", {
    "clicked": true, "x": 225, "y": 50,
    "mouseDownX": 225, "mouseDownY": 50,
    "hover": false, "drag": false, "mouseUp": false,
    "doubleClick": false, "rightClick": false
});
/compile

# Verify
/expect display.data.threshold is 0.75
/expect display.data.dragging is 1
/exit
// end test
