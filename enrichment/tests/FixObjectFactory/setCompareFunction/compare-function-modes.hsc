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
const var factory = Engine.createFixObjectFactory({
    "id": 0,
    "score": 0.0
});

var arr = factory.createArray(3);

// Set values for sorting
arr[0].id = 3;
arr[0].score = 1.5;
arr[1].id = 1;
arr[1].score = 3.0;
arr[2].id = 2;
arr[2].score = 0.5;

// Sort by custom function (descending score)
inline function descByScore(a, b)
{
    if (a.score > b.score) return -1;
    if (a.score < b.score) return 1;
    return 0;
};

factory.setCompareFunction(descByScore);
arr.sort();

Console.print(arr[0].score); // 3.0

// Switch to optimized property comparator (ascending by score)
factory.setCompareFunction("score");
arr.sort();

Console.print(arr[0].score); // 0.5
Console.print(arr[1].score); // 1.5
Console.print(arr[2].score); // 3.0
// test
/compile

# Verify
/expect-logs ["3.0", "0.5", "1.5", "3.0"]
/exit
// end test
