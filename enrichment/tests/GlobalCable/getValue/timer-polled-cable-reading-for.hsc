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
// Context: A ScriptPanel displays a modulation ring that shows the
// current cable value as an arc. The panel polls the cable on a
// timer rather than using a callback, which is simpler when the
// only consumer is a visual element.

const var rm = Engine.getGlobalRoutingManager();

const var ModDisplay = Content.addPanel("ModRing", 0, 0);

// Store the cable reference in the panel's data object so the
// timer callback can access it without a namespace lookup
ModDisplay.data.cable = rm.getCable("ModulationValue");

ModDisplay.setPaintRoutine(function(g)
{
    local arc = Content.createPath();
    local start = 2.4;
    local sweep = 2.0 * this.data.cable.getValue() * start;

    arc.startNewSubPath(0.0, 0.0);
    arc.startNewSubPath(1.0, 1.0);
    arc.addArc([0.0, 0.0, 1.0, 1.0], -start, -start + sweep);

    g.setColour(0x8800CCFF);
    g.drawPath(arc, this.getLocalBounds(3), 2.0);
});

ModDisplay.setTimerCallback(function()
{
    this.repaint();
});

ModDisplay.startTimer(30);
// test
ModDisplay.data.cable.setValue(0.5);
/compile

# Verify
/expect ModDisplay.data.cable.getValue() is 0.5
/exit
// end test
