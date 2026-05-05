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
// Context: When generating a clean identifier from user-provided text,
// remove special characters that are not valid in IDs.

var userTag = "My/Tag\\Name";
var cleanTag = userTag.replace("\\", "").replace("/", "").trim();
Console.print(cleanTag); // MyTagName
// test
/compile

# Verify
/expect-logs ["MyTagName"]
/exit
// end test
