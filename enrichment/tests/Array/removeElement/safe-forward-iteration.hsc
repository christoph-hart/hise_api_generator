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
// Context: When removing elements during a forward loop, decrement
// the index after removal to avoid skipping the next element.

// Remove expired entries from a tracking stack
const var stack = [
    {"progress": 0.5},
    {"progress": 1.2},
    {"progress": 0.8},
    {"progress": 1.5},
    {"progress": 0.3}
];

for(i = 0; i < stack.length; i++)
{
    if(stack[i].progress > 1.0)
        stack.removeElement(i--);
}

Console.print(stack.length); // 3
// test
/compile

# Verify
/expect-logs ["3"]
/expect stack[1].progress is 0.8
/exit
// end test
