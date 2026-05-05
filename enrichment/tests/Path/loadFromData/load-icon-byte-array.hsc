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
// Title: Loading an SVG-converted icon from a byte array
// Context: The most common loadFromData pattern uses numeric arrays
// exported from SVG conversion tools. The icon is loaded once at
// initialization and drawn repeatedly in paint routines or LAF
// callbacks. The byte array is JUCE's binary path format, not raw
// SVG data.

const var iconData = [110, 109, 128, 74, 123, 67, 0, 47, 253, 67,
    108, 128, 74, 123, 67, 128, 215, 0, 68, 108, 0, 216, 125, 67,
    128, 215, 0, 68, 108, 0, 216, 125, 67, 0, 47, 253, 67, 108,
    128, 74, 123, 67, 0, 47, 253, 67, 99];

const var icon = Content.createPath();
icon.loadFromData(iconData);
// test
/compile

# Verify
/expect icon.getLength() > 0 is true
/exit
// end test
