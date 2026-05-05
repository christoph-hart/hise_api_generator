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
const var es = Engine.createUnorderedStack();

// Built-in compare by event ID (matches note-on/off pairs)
es.setIsEventStack(true, es.EventId);

// Custom compare function (matches by note number only)
const var es2 = Engine.createUnorderedStack();

inline function compareByNote(a, b)
{
    return a.getNoteNumber() == b.getNoteNumber();
};

es2.setIsEventStack(true, compareByNote);
// test
const var h1 = Engine.createMessageHolder();
h1.setNoteNumber(60);
h1.setVelocity(100);
es.insert(h1);

const var h2 = Engine.createMessageHolder();
h2.setNoteNumber(64);
h2.setVelocity(90);
es2.insert(h2);
/compile

# Verify
/expect es.size() is 1
/expect es2.size() is 1
/exit
// end test
