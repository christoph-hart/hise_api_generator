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
// Title: Converting a Rectangle back to [x,y,w,h] for APIs that expect arrays
// Context: Some older utility functions or third-party include files expect
// plain [x,y,w,h] arrays. Use toArray() to bridge between Rectangle objects
// and array-based APIs.

var rect = Rectangle(10, 20, 300, 200);
var header = rect.removeFromTop(50);

// Pass to a function that expects a plain array
var arr = header.toArray();

// Also useful for storing layout data as JSON-serializable values
var layoutData = {
    "header": header.toArray(),
    "content": rect.toArray()
};
// test
/compile

# Verify
/expect arr[0] is 10
/expect arr[1] is 20
/expect arr[2] is 300
/expect arr[3] is 50
/expect layoutData.content[1] is 70
/expect layoutData.content[3] is 150
/exit
// end test
