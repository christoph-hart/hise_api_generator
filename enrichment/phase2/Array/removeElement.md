## removeElement

**Examples:**


**Pitfalls:**
- Forgetting `i--` when removing in a forward loop is the most common Array bug in production code. After `removeElement(i)`, element `i+1` shifts to index `i` and gets skipped on the next iteration.
