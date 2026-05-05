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
// Title: Timer that counts ticks and stops itself
const var t = Engine.createTimerObject();

reg tickCount = 0;

inline function onTimerTick()
{
    tickCount++;

    if (tickCount >= 3)
        t.stopTimer();
};

t.setTimerCallback(onTimerTick);
t.startTimer(50);
// test
/compile

# Verify
/wait 500ms
/expect tickCount >= 3 is true
/expect t.isTimerRunning() is false
/exit
// end test
