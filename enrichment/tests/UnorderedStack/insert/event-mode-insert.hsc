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
// Title: Event-mode insertion with MessageHolder
// Context: Inserting events requires a MessageHolder. The current
// MIDI event is captured with Message.store(), then the holder
// is passed to insert(). Duplicate detection uses the configured
// compare function.

const var eventStack = Engine.createUnorderedStack();
const var holder = Engine.createMessageHolder();
eventStack.setIsEventStack(true, eventStack.EventId);

// onNoteOn
inline function handleNoteOn()
{
    Message.store(holder);
    eventStack.insert(holder); // returns false if event ID already present
}
// test
holder.setNoteNumber(60);
holder.setVelocity(100);
eventStack.insert(holder);
/compile

# Verify
/expect eventStack.size() is 1
/exit
// end test
