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
// Context: A voice visualization keeps a fixed-size stack of active
// notes. When the stack is full, find the oldest entry and remove
// it by index before inserting the new one.

const var stack = [];
for(i = 0; i < 130; i++)
    stack.push({"elapsed": i});

const var MAX_VOICES = 128;

// Find the entry with the largest elapsed time (oldest)
if(stack.length >= MAX_VOICES)
{
    var maxIdx = 0;
    var maxValue = 0.0;
    var idx = 0;

    for(s in stack)
    {
        if(s.elapsed > maxValue)
        {
            maxIdx = idx;
            maxValue = s.elapsed;
        }

        idx++;
    }

    stack.removeElement(maxIdx);
}

Console.print(stack.length); // 129
// test
/compile

# Verify
/expect-logs ["129"]
/expect stack[128].elapsed is 128
/exit
// end test
