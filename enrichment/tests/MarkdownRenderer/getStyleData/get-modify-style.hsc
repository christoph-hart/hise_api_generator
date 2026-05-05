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
// Title: Modify existing style incrementally
const var md = Content.createMarkdownRenderer();

var style = md.getStyleData();
style.FontSize = 24.0;
style.textColour = 0xFFCCCCCC;
md.setStyleData(style);
// test
/compile

# Verify
/expect md.getStyleData().FontSize is 24.0
/exit
// end test
