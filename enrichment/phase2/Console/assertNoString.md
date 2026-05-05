## assertNoString

**Examples:**


**Pitfalls:**
- The error message on failure is the string value itself (e.g., `"Assertion failure: hello"`). This can be confusing if the string content resembles a different error. Use `assertWithMessage` if you need a clearer failure message for string-type checks.
