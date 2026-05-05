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
// Title: Safe removal during index-based iteration
// Context: Because removeElement() uses swap-and-pop, the loop index
// must be decremented after each removal to avoid skipping the
// swapped-in element.

const var f = Engine.createFixObjectFactory({
    "eventId": -1,
    "start": 0.0,
    "end": -1.0,
    "active": false
});

const var stack = f.createStack(32);
const var obj = f.create();

// Populate with test data
obj.eventId = 1; obj.end = 0.5; stack.insert(obj);
obj.eventId = 2; obj.end = 2.0; stack.insert(obj);  // expired
obj.eventId = 3; obj.end = 0.3; stack.insert(obj);
obj.eventId = 4; obj.end = 1.5; stack.insert(obj);  // expired

inline function removeExpired()
{
    for (i = 0; i < stack.size(); i++)
    {
        if (stack[i].end > 1.0)
            stack.removeElement(i--);
        //                       ^^ critical: the last element was swapped
        //                          into slot i, so re-check this index
    }
}

removeExpired();
Console.print(stack.size()); // 2
// test
/compile

# Verify
/expect stack.size() is 2
/expect stack[0].end <= 1.0 is true
/expect stack[1].end <= 1.0 is true
/exit
// end test
