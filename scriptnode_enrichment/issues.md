# Scriptnode Enrichment -- Issues Found During Source Analysis

## Issue 1: DataReadLock default behavior is try-read, not blocking read

**File:** `hi_dsp_library/snex_basics/snex_ExternalData.h`, line 833-835

The `DataReadLock` constructor has a `tryRead` parameter that defaults to `false`.
However, when `tryRead` is false, it calls `enterTryReadLock()` (non-blocking).
When `tryRead` is true, it calls `enterReadLock()` (blocking). This is
counter-intuitive -- the parameter name and default suggest "don't try, just
lock", but the implementation does the opposite.

```cpp
if (tryRead)
    holdsLock = lockToUse->enterReadLock();      // blocking
else
    holdsLock = lockToUse->enterTryReadLock();   // non-blocking (default)
```

This means the default `DataReadLock(base*)` is actually a try-lock that may
fail silently. The `operator bool()` check is essential but easy to forget.

**Impact:** Nodes that use `DataReadLock` without checking `isLocked()` may
read stale or inconsistent data if the lock was not acquired. This is likely
intentional for audio-thread safety (never block), but the naming is misleading.

## Issue 2: dyn<float> operator= copies data twice

**File:** `hi_dsp_library/snex_basics/snex_ArrayTypes.h`, lines 609-613

The `operator=(OtherContainer&)` method contains a redundant memcpy:

```cpp
int n = jmin(size(), other.size());
memcpy(begin(), other.begin(), n * sizeof(T));    // first copy (bounded)
memcpy(begin(), other.begin(), size() * sizeof(T)); // second copy (full size)
```

The second memcpy overwrites the first and uses `size()` instead of the bounded
`n`. If `other.size() < size()`, the second memcpy reads past the end of `other`.

**Impact:** Potential out-of-bounds read when source container is smaller than
destination. The jasserts above should catch size mismatches in debug builds.

## Issue 3: math.clip opSingle multiplies instead of clamping

**File:** `hi_dsp_library/dsp_nodes/MathNodes.h`, line 410

The frame-processing path for `math::Operations::clip` contains:
```cpp
s *= jlimit(-value, value, s);
```

This multiplies `s` by the clamped value of `s`, producing `s * clamp(s, -value, value)`.
The block-processing path (line 403) correctly uses `hmath::vclip(b, -value, value)`
which is a pure clamp operation.

**Impact:** Frame-based processing (e.g., inside `fix_block` containers with
blockSize=1, or frame-based container nodes) produces different output than
block-based processing for the same `math.clip` node. The frame path applies a
nonlinear distortion instead of hard clipping. For signals within [-value, value],
the result is `s * s` (squaring), not `s` (identity).

## Issue 4: math.div silently zeroes signal for negative Value parameter

**File:** `hi_dsp_library/dsp_nodes/MathNodes.h`, lines 254, 266

The `math::Operations::div` node checks `value > 0.0f` and sets the factor to
0 for non-positive divisors:
```cpp
auto factor = value > 0.0f ? 1.0f / value : 0.0f;
```

**Impact:** Setting the Value parameter to any negative number produces silence
instead of dividing by a negative value. This is asymmetric with `math.mul`
which works with both positive and negative values. Users expecting `div(-2)` to
invert phase and halve amplitude will get silence instead.

## Issue 5: hmath::sign() inconsistency at zero between float and double

**File:** `hi_dsp_library/snex_basics/snex_Math.h`, lines 149, 169

The double overload uses `value >= 0.0` (returns +1 for zero).
The float overload uses `value > 0.0f` (returns -1 for zero).

```cpp
// double: sign(0.0) = (0.0 >= 0.0) * 2.0 - 1.0 = 1.0
static constexpr double sign(double value) { return (double)(value >= 0.0) * 2.0 - 1.0; };
// float: sign(0.0f) = -1.0f (because 0.0f is not > 0.0f)
static constexpr float sign(float value) { return value > 0.0f ? 1.0f : -1.0f; };
```

**Impact:** `hmath::abs(0.0f)` returns `-0.0f` (negative zero) because abs is
defined as `value * sign(value)` = `0.0f * -1.0f`. This is functionally
equivalent to `0.0f` in IEEE 754 arithmetic but could cause unexpected results
in sign-bit-sensitive comparisons or serialization.

## Issue 6: Clone sanity check has duplicate condition branch

**File:** `hi_snex/snex_cpp_builder/snex_jit_ValueTreeBuilder.cpp`, lines 976-982

The clone container export validation has two branches that check the same
condition with identical logic:

```cpp
if(numStaticClones == -1 && numStaticCableClones != -1)
{
    e.errorMessage << "\n> `Container.NumClones` is automated but `" << cableId << ".NumClones` is static.";
}
else if (numStaticClones == -1 && numStaticCableClones != -1)  // same condition
{
    e.errorMessage << "\n> `Container.NumClones` is static but `" << cableId << ".NumClones` is automated.";
}
```

The second branch (line 980) should check `numStaticClones != -1 && numStaticCableClones == -1`
(the inverse condition). As written, the "static container + automated cable"
case falls through to the generic mismatch message instead of getting the
specific error text.

**Impact:** Misleading error message when a clone container has static NumClones
but a connected clone cable has automated NumClones. The error still fires
(caught by the earlier `numStaticClones != numStaticCableClones` check) but
shows the generic "NumClones mismatch" message instead of the specific one.

## Issue 7: SplitNode::handleHiseEvent passes original instead of copy

**File:** `hi_scripting/scripting/scriptnode/nodes/NodeContainerTypes.cpp`, lines 119-129

The `SplitNode::handleHiseEvent()` creates a copy of the HiseEvent but then
passes the original reference to each child, leaving the copy unused:

```cpp
void SplitNode::handleHiseEvent(HiseEvent& e)
{
    if (isBypassed())
        return;

    for (auto n : nodes)
    {
        HiseEvent copy(e);       // copy created but never used
        n->handleHiseEvent(e);   // should be: n->handleHiseEvent(copy);
    }
}
```

Line 127 should pass `copy` instead of `e`. As written, if the first child
modifies the event (e.g., changes velocity or channel), subsequent children
see the modified version. This makes split event handling behave identically
to chain (serial) event handling, which is likely unintended.

Compare with `MultiChannelNode::handleHiseEvent()` (lines 550-556) which
correctly creates a copy `c` and passes `c` to each child. Also compare with
the compiled `container::split` which passes the same reference by design
(since compiled nodes typically do not modify events in handleHiseEvent).

**Impact:** Low in practice -- most nodes do not modify HiseEvent in
handleHiseEvent(). But any node that does (e.g., transposing, channel
filtering) would cause unexpected cross-talk between split branches.

## Issue 8: wrap::repitch hardcoded to 1 or 2 channels only

**File:** `hi_dsp_library/node_api/nodes/processors.h`, lines 880-901

The `repitch::process()` method dispatches only for 1 or 2 channels:

```cpp
if(data.getNumChannels() == 1)
    processFixed<1>(data);
if(data.getNumChannels() == 2)
    processFixed<2>(data);
```

For channel counts > 2, no processing occurs -- the data passes through
unmodified. There is no assertion or error for unsupported channel counts,
so the failure is silent.

**Impact:** A `container.repitch` inside a `container.fix4_block` (or any
context with > 2 channels) silently does nothing. The child nodes still
process at the original sample rate despite the repitch wrapper being present.

## Issue 9: wrap::dynamic_blocksize has unused static_functions members

**File:** `hi_dsp_library/node_api/nodes/processors.h`, lines 1395-1401

The `dynamic_blocksize` class declares seven `static_functions::fix_block<N>`
member variables (b8, b16, b32, b64, b128, b256, b512) that are never used.
The actual processing dispatches via the BLOCKSIZE_CASE macro which calls
`static_functions::fix_block<N>::process()` as a static function, not through
these member instances.

```cpp
static_functions::fix_block<8> b8;    // never used
static_functions::fix_block<16> b16;  // never used
// ... etc
```

**Impact:** No functional impact. These are empty structs (only contain a
static `SN_EMPTY_INITIALISE` macro) so the memory overhead is negligible.
Likely leftover from an earlier implementation that used member instances.

## Issue 10: clone_forward::createParameters uses clone_cable's DEFINE_PARAMETERDATA

**File:** `hi_dsp_library/dsp_nodes/CableNodes.h`, lines 1685-1691

The `clone_forward::createParameters()` method uses `DEFINE_PARAMETERDATA(clone_cable, ...)`
instead of `DEFINE_PARAMETERDATA(clone_forward, ...)`:

```cpp
// Inside clone_forward::createParameters():
DEFINE_PARAMETERDATA(clone_cable, NumClones);  // should be clone_forward
// ...
DEFINE_PARAMETERDATA(clone_cable, Value);      // should be clone_forward
```

The `DEFINE_PARAMETERDATA` macro uses its first argument to generate the
`setParameterStatic` callback binding. Since `clone_forward` defines its own
`setParameterStatic` via `DEFINE_PARAMETERS` / `SN_PARAMETER_MEMBER_FUNCTION`,
the callback should point to `clone_forward::setParameterStatic`, not
`clone_cable::setParameterStatic`.

**Impact:** In the compiled (exported) path, parameter callbacks are wired at
compile time via template connections, so this macro output is not used. In the
interpreted path, `OpaqueNode::create()` calls `createParameters()` and the
generated `parameter::data` objects carry function pointers. If the macro
resolves to `clone_cable::setParameterStatic`, setting NumClones or Value would
call clone_cable's parameter dispatch instead of clone_forward's. However,
since clone_forward is always instantiated with `parameter::clone_holder`
(dynamic), and the dynamic path uses `clone_holder::callEachClone` directly
rather than these static callbacks, the bug may be masked at runtime.

## Issue 11: filters.svf Allpass mode inconsistency between process and processFrame

- **Type:** inconsistency
- **Severity:** high
- **Location:** `hi_dsp_library/dsp_basics/MultiChannelFilters.cpp`:1075 vs 1173
- **Observed:** In `StateVariableFilterSubType::processSamples()` (block path, line 1075), the HP term for Allpass mode is computed as `(input - x1*z1_A - v2) * x2` (multiply by x2). In `processFrame()` (line 1173), the same HP term is computed as `(input - x1*z1_A - v2) / x2` (divide by x2). Since `x2 = 1/(1 + 2*R*g + g*g)`, multiply and divide by x2 produce different results.
- **Expected:** Both paths should use the same operation. The block path (multiply by x2) matches the standard Zavalishin TPT SVF formulation and is likely correct. The frame path (divide by x2) appears to be a bug.

## Issue 12: filters.moog Mode parameter is display-only, does not affect processing

- **Type:** inconsistency
- **Severity:** medium
- **Location:** `hi_dsp_library/dsp_basics/MultiChannelFilters.cpp`:371-374, 389-412
- **Observed:** `MoogFilterSubType::setType(int /*t*/)` is empty (line 371-374). The Mode parameter (values: "One Pole", "Two Poles", "Four Poles") only affects the filter display curve via `getCoefficientTypeList()`. The `processSamples()` and `processFrame()` methods always run the full 4-pole ladder processing and output from stage 4. The `mode` member variable has a `setMode()` setter that is never called from the FilterNodeBase path (which calls `setType()`, not `setMode()`).
- **Expected:** Either the Mode parameter should switch between 1-pole, 2-pole, and 4-pole outputs (by outputting from out1, out2, or out4 respectively), or the Mode parameter should be removed/hidden and the node documented as always being 4-pole.

## Issue 13: LinkwitzRiley::processSamples incorrect channel pointer and ignores numSamples

- **Type:** silent-fail
- **Severity:** medium
- **Location:** `hi_dsp_library/dsp_basics/MultiChannelFilters.cpp`:1242-1253
- **Observed:** `processSamples(AudioSampleBuffer& buffer, int startSample, int)` has two issues: (1) `buffer.getWritePointer(c + startSample)` passes `c + startSample` as the channel index instead of `buffer.getWritePointer(c, startSample)`. (2) The numSamples parameter is unnamed/ignored; the loop uses `buffer.getNumSamples()` instead. In the scriptnode path, startSample is always 0 (set by FilterNodeBase::process), which mitigates the channel index bug, and the buffer size matches numSamples, which mitigates the loop count issue.
- **Expected:** `auto ptr = buffer.getWritePointer(c, startSample);` and loop should use the numSamples parameter: `for (int i = 0; i < numSamples; i++)`.

## Issue 14: fx.reverb setWidth() sets damping instead of width

- **Type:** inconsistency
- **Severity:** high
- **Location:** `hi_dsp_library/dsp_nodes/FXNodes.cpp`:93-98
- **Observed:** `reverb::setWidth(double width)` sets `p.damping = jlimit(0.0f, 1.0f, (float)width)` instead of `p.width`. This is a copy-paste error from `setDamping()`. The Width parameter has no effect on stereo width -- it modifies damping a second time. The actual `juce::Reverb::Parameters::width` field is never set by the node and remains at the JUCE default value.
- **Expected:** `p.width = jlimit(0.0f, 1.0f, (float)width);`

## Issue 15: fx.sampleandhold existing phase3 doc has wrong parameter name

- **Type:** inconsistency
- **Severity:** medium
- **Location:** `phase3/fx/sampleandhold.md`
- **Observed:** The existing phase3 documentation lists "Position: The position in the stereo field" as the parameter for fx.sampleandhold. The actual parameter is "Counter" (range 1-64, integer). This is a copy-paste error from the fx.haas documentation.
- **Expected:** Parameter should be documented as "Counter" with its correct description (decimation factor for sample rate reduction).
