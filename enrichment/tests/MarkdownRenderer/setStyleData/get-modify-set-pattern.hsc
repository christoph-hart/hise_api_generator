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
// Context: The safe way to change individual style properties without
// resetting others. Get the defaults, modify what you need, set it back.

const var md = Content.createMarkdownRenderer();

// Get current style (preserves all defaults)
const var style = md.getStyleData();

// Modify only what you need
style.headlineColour = 0xFF333333;
style.textColour = 0xFF444444;
style.Font = "Roboto";
style.FontSize = 13.0;

// Table styling - set to transparent for borderless tables
style.tableLineColour = 0;
style.tableHeaderBgColour = 0;
style.tableBgColour = 0;

md.setStyleData(style);
// test
/compile

# Verify
/expect md.getStyleData().FontSize is 13.0
/expect md.getStyleData().tableLineColour is 0
/exit
// end test
