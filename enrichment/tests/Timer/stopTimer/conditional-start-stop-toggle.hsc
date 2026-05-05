// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: UI scaffold
/ui
add ScriptLabel "TooltipLabel" at 0 0 128 32
add ScriptButton "TooltipButton" at 0 50 128 32
/exit

/script
/callback onInit
// end setup
// Title: Conditional start/stop from a toggle button
Content.getComponent("TooltipButton").set("saveInPreset", false);

// Context: A tooltip polling timer that only runs while
// the tooltip feature is enabled.

const var tooltipTimer = Engine.createTimerObject();

tooltipTimer.setTimerCallback(function()
{
    local tt = Content.getCurrentTooltip();

    if (tt.length > 0)
        Content.getComponent("TooltipLabel").set("text", tt);
    else
        Content.getComponent("TooltipLabel").set("text", "");
});

inline function onTooltipToggle(component, value)
{
    if (value)
        tooltipTimer.startTimer(150);
    else
        tooltipTimer.stopTimer();
}

Content.getComponent("TooltipButton").setControlCallback(onTooltipToggle);
// test
/compile

# Initially stopped
/expect tooltipTimer.isTimerRunning() is false

# Toggle on
/ui set TooltipButton.value 1
/expect tooltipTimer.isTimerRunning() is true

# Toggle off
/ui set TooltipButton.value 0
/expect tooltipTimer.isTimerRunning() is false
/exit
// end test
