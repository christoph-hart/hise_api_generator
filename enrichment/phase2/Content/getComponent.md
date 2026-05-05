## getComponent

**Examples:**


**Pitfalls:**
- Calling `Content.getComponent()` inside callbacks, timer functions, or paint routines is a common performance mistake. Each call performs a linear search through all components. In a plugin with hundreds of components, this overhead is measurable. Always cache references as `const var` at init time.
