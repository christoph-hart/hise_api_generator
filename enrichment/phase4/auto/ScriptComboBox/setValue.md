Sets the selected item by 1-based integer index. Value 1 selects the first item, value 0 clears the selection and shows the placeholder text. This method is thread-safe and can be called from any thread; the UI update happens asynchronously.

> [!Warning:$WARNING_TO_BE_REPLACED$] If called during `onInit`, the value is not restored after recompilation. Set the `defaultValue` property instead for persistent initial values.
