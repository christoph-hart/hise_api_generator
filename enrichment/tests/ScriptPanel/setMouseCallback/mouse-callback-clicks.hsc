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
const var pnl = Content.addPanel("ClickPanel", 0, 0);
pnl.set("width", 200);
pnl.set("height", 100);
pnl.set("allowCallbacks", "Clicks Only");

pnl.data.clickCount = 0;

inline function onMouse(event)
{
    if (event.clicked)
    {
        this.data.clickCount++;
        this.repaint();
    }
};

pnl.setMouseCallback(onMouse);

pnl.setPaintRoutine(function(g)
{
    g.fillAll(0xFF333333);
    g.setColour(0xFFFFFFFF);
    g.drawAlignedText("Clicks: " + this.data.clickCount, [0, 0, this.getWidth(), this.getHeight()], "centred");
});

pnl.repaint();
// test
Console.testCallback(pnl, "setMouseCallback", {
    "clicked": true, "x": 100, "y": 50,
    "mouseDownX": 100, "mouseDownY": 50,
    "mouseUp": false, "doubleClick": false, "rightClick": false
});
/compile

# Verify
/expect pnl.data.clickCount is 1
/exit
// end test
