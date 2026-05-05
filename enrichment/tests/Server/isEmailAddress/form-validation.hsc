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
// Context: Client-side email validation for a contact or feedback form.
// isEmailAddress() runs a quick structural check (no server round-trip),
// making it suitable for real-time input validation.

const var emailInput = Content.addLabel("EmailInput", 10, 10);
emailInput.set("editable", true);
emailInput.set("text", "");
emailInput.set("saveInPreset", false);

const var submitButton = Content.addButton("SubmitButton", 10, 50);
submitButton.set("enabled", false);
submitButton.set("saveInPreset", false);

reg lastValidResult = -1;

inline function onEmailChanged(component, value)
{
    local isValid = Server.isEmailAddress(value);
    lastValidResult = isValid;

    // Enable the button only when the email looks valid
    submitButton.set("enabled", isValid);

    if (!isValid && value.length > 0)
        Console.print("Please enter a valid email address");
};

emailInput.setControlCallback(onEmailChanged);
// test
/compile

# Trigger
/ui set EmailInput.value "test@domain.com"

# Verify
/expect Server.isEmailAddress('user@example.com') is 1
/expect Server.isEmailAddress('not-an-email') is 0
/expect lastValidResult is 1
/exit
// end test
