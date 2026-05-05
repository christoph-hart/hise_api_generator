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
const var f1 = Engine.createFixObjectFactory({
	"myValue": 17,
	"someOtherValue": 42.0
});

// Creates a preallocated array with the given size
const var list = f1.createArray(64);

// Creates an object for interacting with the array above
const var obj = f1.create();

Console.print(trace(obj));

// Now we want to push an object with both values zero
// into the list. 
obj.myValue = 0;
obj.someOtherValue = 0.0;

// This will not insert a reference into the array but copy the 
// data values from the current state of obj
list[0] = obj;

// You can also call trace with a FixObjectArray and it will dump it like a JSON
Console.print(trace(list));

// this function will perform a bitwise comparison of the data
const var idx = list.indexOf(obj);
Console.print(idx); // => 0

obj.myValue = 90;

// Now it won't find the element because we changed it.
// Note that that's different from the default JS behaviour
// because we are not storing a reference to the object in the 
// array but a copy!
const var idx2 = list.indexOf(obj);

Console.print(idx2); // => -1
// test
/compile

# Verify
/expect idx is 0
/expect idx2 is -1
/exit
// end test
