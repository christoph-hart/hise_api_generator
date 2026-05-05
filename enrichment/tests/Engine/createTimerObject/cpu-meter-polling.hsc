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
// Title: CPU meter with periodic polling
// Context: Timer objects are the standard way to poll engine state
// for UI display. This pattern appears in nearly every plugin that
// shows CPU usage, peak levels, or loading progress.

const var cpuLabel = Content.addLabel("CpuLabel", 10, 10);
cpuLabel.set("editable", false);

const var cpuTimer = Engine.createTimerObject();

cpuTimer.setTimerCallback(function()
{
    cpuLabel.set("text", parseInt(Engine.getCpuUsage()) + "% CPU");
});

// 500ms is a good default for diagnostic displays
cpuTimer.startTimer(500);
// test
/compile

# Verify
/wait 600ms
/expect cpuLabel.get("text").contains("CPU") is true
/exit
// end test
