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
// Title: Creating and configuring a child panel
const var pnl = Content.addPanel("ParentPanel", 0, 0);
pnl.set("width", 300);
pnl.set("height", 200);

var child = pnl.addChildPanel();
child.set("width", 100);
child.set("height", 50);
child.set("x", 10);
child.set("y", 10);

child.setPaintRoutine(function(g)
{
    g.fillAll(0xFF444444);
});

child.repaint();
// test
/compile

# Verify
/expect pnl.getChildPanelList().length is 1
/expect child.getWidth() is 100
/exit
// end test
