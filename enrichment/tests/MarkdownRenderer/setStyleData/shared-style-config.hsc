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
// Title: Define a reusable style configuration object
// Context: When multiple renderers share the same visual theme,
// define the style as a standalone JSON object and pass it
// to each renderer's setStyleData().

const var DARK_THEME_STYLE = {
    "Font": "Roboto",
    "BoldFont": "Roboto Bold",
    "FontSize": 14.0,
    "bgColour": 0,
    "codeBgColour": 0,
    "linkBgColour": 0,
    "textColour": 0x88FFFFFF,
    "codeColour": 0xFFAAAAEE,
    "linkColour": 0xFF6666EE,
    "headlineColour": 0xFF5F9EA0,
    "tableHeaderBgColour": 0,
    "tableLineColour": 0,
    "tableBgColour": 0,
    "UseSpecialBoldFont": false
};

// Apply the same theme to multiple renderers
const var dialogMd = Content.createMarkdownRenderer();
dialogMd.setStyleData(DARK_THEME_STYLE);

const var errorMd = Content.createMarkdownRenderer();
errorMd.setStyleData(DARK_THEME_STYLE);

// The style object can also be used for consistent font/colour
// choices in other drawing code alongside the markdown
// test
/compile

# Verify
/expect dialogMd.getStyleData().FontSize is 14.0
/expect errorMd.getStyleData().FontSize is 14.0
/exit
// end test
