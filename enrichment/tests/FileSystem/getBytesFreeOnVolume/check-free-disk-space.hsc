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
// Title: Check free disk space on the samples volume
var freeBytes = FileSystem.getBytesFreeOnVolume(FileSystem.Samples);
var freeText = FileSystem.descriptionOfSizeInBytes(freeBytes);

Console.print("Free space on samples volume: " + freeText);
// test
/compile

# Verify
/expect freeBytes > 0 is true
/exit
// end test
