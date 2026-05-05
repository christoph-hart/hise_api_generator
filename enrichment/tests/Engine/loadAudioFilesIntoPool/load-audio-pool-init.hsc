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
// Context: Call loadAudioFilesIntoPool() in onInit before any
// code that references audio files from scripts. In compiled
// plugins, this ensures the embedded pool references are loaded.

const var poolRefs = Engine.loadAudioFilesIntoPool();

// poolRefs is an array of all audio file references in the pool.
// The count depends on which audio files exist in the project.
Console.print("Pool refs is array: " + Array.isArray(poolRefs));
// test
/compile

# Verify
/expect-logs ["Pool refs is array: 1"]
/exit
// end test
