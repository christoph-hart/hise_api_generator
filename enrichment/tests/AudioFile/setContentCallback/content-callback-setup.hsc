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
const var af = Engine.createAndRegisterAudioFile(0);

reg callCount = 0;

inline function onContentChanged()
{
    // 'this' points to the AudioFile that changed
    Console.print("Content changed: " + this.getNumSamples() + " samples");
    callCount++;
};

af.setContentCallback(onContentChanged);
// test
const var trigBuf = Buffer.create(64);
af.loadBuffer(trigBuf, 44100.0, []);
/compile

# Verify
/wait 500ms
/expect callCount is 1
/exit
// end test
