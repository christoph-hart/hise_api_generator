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
// Title: Guard clauses in a data-binding utility
// Context: Validate preconditions at the start of utility functions
// that access panel data properties. Each assertion targets a specific
// failure mode that would otherwise produce a cryptic error downstream.

const var panel = Content.addPanel("TestPanel", 0, 0);
panel.data.testProperty = 42;

inline function setProperty(panel, name, value)
{
    Console.assertTrue(isDefined(panel));
    Console.assertTrue(isDefined(name));
    Console.assertTrue(isDefined(panel.data));
    Console.assertTrue(isDefined(panel.data[name]));

    panel.data[name] = value;
}

setProperty(panel, "testProperty", 100);
// test
/compile

# Verify
/expect panel.data.testProperty is 100
/exit
// end test
