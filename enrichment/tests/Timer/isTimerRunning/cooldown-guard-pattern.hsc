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
// Context: isTimerRunning() serves as a debounce gate to prevent
// re-triggering an operation while its cooldown timer is active.

const var loadTimer = Engine.createTimerObject();

loadTimer.setTimerCallback(function()
{
    this.stopTimer();
});

reg operationCount = 0;

inline function doExpensiveOperation()
{
    operationCount++;
};

inline function onPresetChange(component, value)
{
    if (loadTimer.isTimerRunning())
        return; // Still in cooldown -- ignore rapid changes

    // Execute the operation and start cooldown
    doExpensiveOperation();
    loadTimer.startTimer(200);
}
// test
onPresetChange(0, 1);
onPresetChange(0, 1);
/compile

# Verify
/expect operationCount is 1
/expect loadTimer.isTimerRunning() is true
/wait 500ms
/expect loadTimer.isTimerRunning() is false
/exit
// end test
