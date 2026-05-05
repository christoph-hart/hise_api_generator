// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: UI scaffold
/ui
add ScriptPanel "PeakMeter" at 0 0 128 48
/exit

/script
/callback onInit
// end setup
// Context: Peak meters poll the master output level from a timer
// callback and update a panel's paint routine. The timer interval
// controls the visual smoothness of the meter.
const var peakPanel = Content.getComponent("PeakMeter");

reg peakL = 0.0;
reg peakR = 0.0;

const var peakTimer = Engine.createTimerObject();

peakTimer.setTimerCallback(function()
{
    peakL = Engine.getMasterPeakLevel(0);
    peakR = Engine.getMasterPeakLevel(1);
    peakPanel.repaint();
});

peakTimer.startTimer(30);

peakPanel.setPaintRoutine(function(g)
{
    local a = this.getLocalBounds(0);
    local halfW = a[2] / 2;

    g.setColour(0xFF1A1A1A);
    g.fillRect(a);

    // Left channel
    g.setColour(0xFF4CAF50);
    g.fillRect([0, a[3] * (1.0 - peakL), halfW - 1, a[3] * peakL]);

    // Right channel
    g.fillRect([halfW + 1, a[3] * (1.0 - peakR), halfW - 1, a[3] * peakR]);
});
// test
/compile

# Verify
/expect Engine.getMasterPeakLevel(0) >= 0.0 is true
/expect Engine.getMasterPeakLevel(1) >= 0.0 is true
/exit
// end test
