## removeElement

**Examples:**


**Pitfalls:**
- Forgetting `i--` after `removeElement(i)` in a forward loop is the most common FixObjectStack bug. The swap-and-pop moves the last used element into slot `i`. Without decrementing, the loop advances to `i+1` and the swapped element is never checked.
