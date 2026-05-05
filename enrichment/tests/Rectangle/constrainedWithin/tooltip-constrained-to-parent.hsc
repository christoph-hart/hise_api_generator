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
// Context: Positioning a tooltip or popup element near a target control,
// then constraining it so it does not overflow the parent panel's bounds.

const var TOOLTIP_WIDTH = 110;
const var TOOLTIP_HEIGHT = 24;

inline function getTooltipBounds(targetBounds, parentBounds)
{
    // Position tooltip centered below the target, offset 5px down
    var tooltip = Rectangle(
        targetBounds.x + (targetBounds.width - TOOLTIP_WIDTH) / 2,
        targetBounds.y + targetBounds.height + 5,
        TOOLTIP_WIDTH,
        TOOLTIP_HEIGHT
    );

    // Clamp to parent bounds so it doesn't overflow the edges
    return tooltip.constrainedWithin(parentBounds);
}

var target = Rectangle(350, 10, 40, 40);
var parent = Rectangle(0, 0, 400, 300);
var tip = getTooltipBounds(target, parent);
// tooltip slides left to stay within the 400px-wide parent
// test
/compile

# Verify
/expect tip.width is 110
/expect tip.height is 24
/expect tip.x + tip.width <= 400 is true
/expect tip.y is 55
/exit
// end test
