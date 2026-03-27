Renders an OpenGL shader into the specified rectangular area. The shader must be a `ScriptShader` object. Returns `true` if the shader was valid and the draw action was queued, or `false` if the shader parameter was invalid. This method does not require an active layer.

> [!Warning:$WARNING_TO_BE_REPLACED$] Requires OpenGL to be enabled. Shader compilation errors are only logged to the console in the HISE IDE - in exported plugins, a failed shader silently renders nothing.
