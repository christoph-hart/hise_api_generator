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
var secret = "Hello World";
var key = "mySecretKey";
var encrypted = secret.encrypt(key);
var decrypted = encrypted.decrypt(key);
Console.print(decrypted); // Hello World
// test
/compile

# Verify
/expect-logs ["Hello World"]
/exit
// end test
