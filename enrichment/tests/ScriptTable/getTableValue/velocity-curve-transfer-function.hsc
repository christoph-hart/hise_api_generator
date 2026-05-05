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
// Context: A MIDI script shapes incoming velocity with a user-editable curve.

const var velocityCurve = Content.addTable("VelocityCurve", 10, 10);
velocityCurve.set("width", 240);
velocityCurve.set("height", 100);
velocityCurve.addTablePoint(0.5, 0.25);

inline function applyVelocityCurve(inputVelocity)
{
    local normalized = inputVelocity / 127.0;
    local mapped = velocityCurve.getTableValue(normalized);
    return Math.max(1, Math.round(mapped * 127.0));
}
// test
/compile

# Verify
/expect Math.round(velocityCurve.getTableValue(0.5) * 100) / 100 is 0.25
/expect applyVelocityCurve(127) is 127
/exit
// end test
