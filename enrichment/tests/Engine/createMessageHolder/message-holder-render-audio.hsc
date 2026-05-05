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
// Context: MessageHolder objects are used to build MIDI event
// sequences for Engine.renderAudio(). Each event needs its type,
// note number, velocity, channel, and timestamp set explicitly.

inline function renderNoteToBuffer(noteNumber, lengthInSamples)
{
    local noteOn = Engine.createMessageHolder();
    local noteOff = Engine.createMessageHolder();

    noteOn.setType(noteOn.cycleId);
    noteOn.setNoteNumber(noteNumber);
    noteOn.setVelocity(100);
    noteOn.setChannel(1);
    noteOn.setTimestamp(0);

    noteOff.setType(noteOff.cycleId);
    noteOff.setNoteNumber(noteNumber);
    noteOff.setVelocity(0);
    noteOff.setChannel(1);
    noteOff.setTimestamp(lengthInSamples);

    local events = [noteOn, noteOff];

    Engine.renderAudio(events, function(status)
    {
        if (status.finished)
            Console.print("Rendered " + status.channels.length + " channels");
    });
}
// test
// Verify MessageHolder construction (renderAudio is async so not verified here)
const var testHolder = Engine.createMessageHolder();
testHolder.setNoteNumber(60);
testHolder.setVelocity(100);
testHolder.setChannel(1);
/compile

# Verify
/expect testHolder.getNoteNumber() is 60
/expect testHolder.getVelocity() is 100
/expect testHolder.getChannel() is 1
/exit
// end test
