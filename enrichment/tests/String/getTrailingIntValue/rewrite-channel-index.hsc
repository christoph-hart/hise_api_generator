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
// Title: Rewrite a component ID to target a different channel index
// Context: When copying parameter state between channels, replace
// the trailing number in the automation ID to point at the new channel.

var id = "PlayerVolume3";
var currentIndex = id.getTrailingIntValue(); // 3

// Replace the trailing "3" with the new channel index
var newId = id.replace(currentIndex, 5);
Console.print(newId); // PlayerVolume5
// test
/compile

# Verify
/expect-logs ["PlayerVolume5"]
/exit
// end test
