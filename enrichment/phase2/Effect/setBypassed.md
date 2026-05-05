## setBypassed

**Examples:**


**Pitfalls:**
- When switching between multi-output and stereo modes, the bypass strategy must change. In multi-output mode, use `setBypassed()` for on/off control. In stereo mode, use an internal enable parameter instead (`fx.setAttribute(fx.InternalEnable, value)`) so the enable state is stored in presets. Mixing the two approaches causes state confusion across preset loads.
