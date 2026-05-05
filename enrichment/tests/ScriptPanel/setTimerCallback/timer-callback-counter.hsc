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
const var pnl = Content.addPanel("TimerPanel", 0, 0);
pnl.set("width", 200);
pnl.set("height", 50);

pnl.data.counter = 0;

inline function onTimer()
{
    this.data.counter++;
    this.repaint();
};

pnl.setTimerCallback(onTimer);

pnl.setPaintRoutine(function(g)
{
    g.fillAll(0xFF222222);
    g.setColour(0xFFFFFFFF);
    g.drawAlignedText("Count: " + this.data.counter, [0, 0, this.getWidth(), this.getHeight()], "centred");
});

pnl.startTimer(100);
pnl.repaint();
// test
/compile

# Verify
/wait 500ms
/expect pnl.data.counter > 0 is true
/exit
// end test
