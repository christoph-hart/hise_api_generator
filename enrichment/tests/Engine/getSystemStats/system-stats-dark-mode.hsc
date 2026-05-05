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
// Title: Adapt UI theme based on OS dark mode setting
var stats = Engine.getSystemStats();
var useDarkTheme = stats.isDarkMode;
Console.print("Dark mode: " + useDarkTheme);
Console.print("CPU: " + stats.CpuModel);
Console.print("RAM: " + stats.MemorySizeInMegabytes + " MB");
// test
/compile

# Verify
/expect typeof stats.CpuModel is "string"
/expect stats.MemorySizeInMegabytes > 0 is true
/expect stats.isDarkMode == 0 || stats.isDarkMode == 1 is true
/expect stats.NumCpus > 0 is true
/exit
// end test
