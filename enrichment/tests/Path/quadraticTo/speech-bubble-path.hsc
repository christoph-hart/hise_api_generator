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
// Context: quadraticTo creates smooth rounded corners on custom
// shapes that addRoundedRectangle cannot express - like a speech
// bubble with an arrow pointer on one side.

const var SHADOW = 10;
const var CORNER = 3;

inline function createBubblePath(width, height)
{
    local p = Content.createPath();
    local r = width - SHADOW;

    // Top edge with rounded corners
    p.startNewSubPath(SHADOW + CORNER, SHADOW);
    p.lineTo(r - CORNER, SHADOW);
    p.quadraticTo(r, SHADOW, r, SHADOW + CORNER);

    // Right edge with arrow pointer
    p.lineTo(r, 20);
    p.lineTo(r + 10, 30);
    p.lineTo(r, 40);
    p.lineTo(r, height - SHADOW - CORNER);

    // Bottom-right corner
    p.quadraticTo(r, height - SHADOW,
                  r - CORNER, height - SHADOW);

    // Bottom edge
    p.lineTo(SHADOW + CORNER, height - SHADOW);

    // Bottom-left corner
    p.quadraticTo(SHADOW, height - SHADOW,
                  SHADOW, height - CORNER - SHADOW);

    // Left edge back to start
    p.lineTo(SHADOW, SHADOW + CORNER);
    p.quadraticTo(SHADOW, SHADOW,
                  SHADOW + CORNER, SHADOW);

    p.closeSubPath();
    return p;
}

const var bubble = createBubblePath(200, 100);
// test
/compile

# Verify
/expect bubble.getLength() > 0 is true
/expect bubble.contains([100, 50]) is true
/exit
// end test
