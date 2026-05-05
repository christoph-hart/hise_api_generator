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
// Context: Level meters and status LEDs typically need a dim "off" state
// and a bright "on" state derived from the same base colour. Computing
// these once at init and storing as const var avoids per-frame
// Colours method calls during paint.

const var LED_BASE = 0xFF5B6870;
const var LED_OFF  = Colours.withMultipliedBrightness(LED_BASE, 0.1);
const var LED_ON   = Colours.withMultipliedBrightness(LED_BASE, 1.5);

Console.print(LED_OFF);  // very dark variant
Console.print(LED_ON);   // boosted brightness (clamped internally)
// test
/compile

# Verify
/expect LED_OFF != LED_ON is true
/expect Colours.toVec4(LED_OFF)[0] < Colours.toVec4(LED_BASE)[0] is true
/expect Colours.toVec4(LED_ON)[0] > Colours.toVec4(LED_BASE)[0] is true
/exit
// end test
