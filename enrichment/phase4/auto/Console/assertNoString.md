Throws a script error if `value` is a string. Used to catch accidental string-to-number coercion bugs when a parameter should be numeric.

> [!Warning:$WARNING_TO_BE_REPLACED$] The error message is the string value itself (e.g., `"Assertion failure: hello"`). This can be confusing if the string content resembles a different error. Use `assertWithMessage` if you need a clearer failure message.
