# Deprecated Methods

Methods listed here are considered deprecated. Phase 1 agents must mark
these as disabled with reason "deprecated" in the class methods.md file.
The text under each heading provides the rationale.

Format: ### ClassName.methodName()
Use * as ClassName for methods deprecated across all inheriting classes.

---

### *.setColour()

This method is super old and is superseded by the set(colourId, value)
method that takes in a named colour ID instead of a weird magic number.
