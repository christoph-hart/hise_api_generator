// setup

# Startup & health check
/hise
/expect status contains online or abort
playground open
/exit

/builder reset

# Setup: UI scaffold
/ui
add ScriptLabel "StatusLabel" at 0 0 128 32
/exit

/script
/callback onInit
// end setup
// Title: One-shot self-stopping timer for delayed action
// Context: Use this.stopTimer() inside the callback to fire once after
// a delay, similar to setTimeout() in JavaScript.

const var statusLabel = Content.getComponent("StatusLabel");

const var delayTimer = Engine.createTimerObject();

delayTimer.setTimerCallback(function()
{
    this.stopTimer();
    statusLabel.set("text", "");
});

// Call this from any event to show a temporary status message
inline function showStatus(text)
{
    statusLabel.set("text", text);
    delayTimer.startTimer(2000);
}
// test
showStatus("test");
delayTimer.startTimer(50);
/compile

# Verify
/wait 300ms
/expect delayTimer.isTimerRunning() is false
/expect statusLabel.get('text') is ""
/exit
// end test
