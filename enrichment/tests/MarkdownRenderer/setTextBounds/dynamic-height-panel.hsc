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
// Title: Size a ScriptPanel to fit markdown content
const var md = Content.createMarkdownRenderer();
md.setText("# Title\nParagraph one.\n\n- Item A\n- Item B\n- Item C");

var requiredHeight = md.setTextBounds([0, 0, 400, 1000]);

// Changing the text invalidates the previous height
md.setText("Short.");
var shortHeight = md.setTextBounds([0, 0, 400, 1000]);
// test
/compile

# Verify
/expect requiredHeight > 50 is true
/expect shortHeight < requiredHeight is true
/exit
// end test
