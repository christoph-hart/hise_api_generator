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
// Context: Positioning a label area below a slider's drag region, centered
// and offset slightly downward. Demonstrates fluent chaining of
// removeFromBottom -> withSizeKeepingCentre -> translated.

var sliderBounds = Rectangle(0, 0, 80, 100);

// Slice the bottom 20px, center it to 100px wide, nudge 5px down
var labelArea = sliderBounds.removeFromBottom(20)
    .withSizeKeepingCentre(100, 20)
    .translated(0, 5);
// test
/compile

# Verify
/expect labelArea.width is 100
/expect labelArea.height is 20
/expect labelArea.y is 85
/expect sliderBounds.height is 80
/exit
// end test
