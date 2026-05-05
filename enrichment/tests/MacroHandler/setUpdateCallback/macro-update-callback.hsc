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
const var mh = Engine.createMacroHandler();

inline function onMacroUpdate(macroData)
{
    Console.print("Connections: " + macroData.length);
};

mh.setUpdateCallback(onMacroUpdate);
// test
/compile

# Verify
/expect-logs ["Connections: 0"]
/exit
// end test
