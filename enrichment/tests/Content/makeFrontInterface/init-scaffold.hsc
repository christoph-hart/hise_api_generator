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
// Title: Standard interface initialization scaffold
// Context: This is always the very first line of the main interface script.
// It sets the interface size and registers this script processor as the
// front interface. Everything else follows after this call.

Content.makeFrontInterface(900, 600);

// Optional: enable HiDPI for custom-drawn panels
Content.setUseHighResolutionForPanels(true);

// Create the UI components
const var mainPanel = Content.addPanel("MainPanel", 0, 0);
mainPanel.set("width", 900);
mainPanel.set("height", 600);

const var gainKnob = Content.addKnob("GainKnob", 10, 10);
const var bypassBtn = Content.addButton("BypassBtn", 150, 10);

const var size = Content.getInterfaceSize();
Console.print(size[0]); // 900
Console.print(size[1]); // 600
// test
/compile

# Verify
/expect size[0] is 900
/expect size[1] is 600
/exit
// end test
