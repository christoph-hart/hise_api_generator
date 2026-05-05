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
var desktop = FileSystem.getFolder(FileSystem.Desktop);
var appData = FileSystem.getFolder(FileSystem.AppData);
var samples = FileSystem.getFolder(FileSystem.Samples);

if (isDefined(desktop))
    Console.print("Desktop: " + desktop.toString(desktop.FullPath));

if (isDefined(appData))
    Console.print("AppData: " + appData.toString(appData.FullPath));

if (isDefined(samples))
    Console.print("Samples: " + samples.toString(samples.FullPath));
// test
/compile

# Verify
/expect desktop.toString(0).length > 0 is true
/expect appData.toString(0).length > 0 is true
/exit
// end test
