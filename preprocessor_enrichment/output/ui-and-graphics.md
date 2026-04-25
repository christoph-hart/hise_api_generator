---
title: UI & Graphics
description: Plugin UI code-path toggles — OpenGL rendering, bundled Lato font, alert look-and-feel, floating tiles, registration overlay, splash screen.
---

Preprocessors in this category shape the plugin's user interface and rendering path. They turn OpenGL rendering on or off by default, include the bundled Lato font as the global default, enable the custom alert window look-and-feel, register external custom floating tiles, swap the default registration overlay for custom script-driven UI, toggle the startup splash screen, and gate the big scriptnode-template compilation path that produces heavier UI widgets. None of these affect the audio engine; all they change is which UI code is compiled in and which default appearance users see on first launch. Disabling optional parts of this group is the easiest way to trim compile time and binary size for headless or utility builds.

### `HISE_DEACTIVATE_OVERLAY`

Hides the built-in dark error overlay so a project can present its own UI for engine errors.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Controls the default value of the overlay that the engine draws on top of the interface whenever something goes wrong (samples not installed, licence missing, incorrect audio folder and similar). When enabled, the overlay is suppressed entirely and the user only sees whatever the project itself shows in response. When disabled, the stock overlay with its default message and buttons is drawn automatically. The scripted error handler object flips the same switch from HISEScript, so creating an ErrorHandler from a script has the same end result as setting this flag at compile time.
> Suppressing the overlay without providing a scripted replacement leaves the user with no feedback when samples are missing or the licence has expired, so only set this when you implement custom error handling in the interface.

**See also:** $API.ErrorHandler$ -- scripted error handler disables the same overlay at runtime and should replace it with custom UI

### `HISE_DEFAULT_OPENGL_VALUE`

Initial OpenGL rendering state when the plugin is launched for the first time on a machine.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Picks the default for the Open GL toggle in the audio settings window and the standalone preferences, so a fresh installation starts either with hardware-accelerated rendering on or off depending on this value. Only consulted when the user has not yet stored an OPEN_GL choice in their settings file; subsequent launches read whatever the user selected last. Ignored entirely unless OpenGL support has been compiled in through the companion flag.
> The user can still flip the renderer in the settings window at runtime, so this only influences the very first launch on a given machine.

**See also:** $PP.HISE_USE_OPENGL_FOR_PLUGIN$ -- only consulted when OpenGL support is actually compiled into the plugin, $API.Settings.isOpenGLEnabled$ -- Settings.isOpenGLEnabled reports the persisted value that this default seeds

### `HISE_USE_CUSTOM_ALERTWINDOW_LOOKANDFEEL`

Lets the project supply its own look and feel for JUCE alert windows instead of the HISE default.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

By default HISE installs an alert-window look and feel that paints native popups (confirmation dialogs, error alerts, prompt boxes) in the same dark style as the rest of the editor, and falls back to the currently active scripted look and feel when one is attached. Enabling this flag skips that registration so the project can install a bespoke alert window style through C++ and avoid the stock HISE styling. Only relevant for projects that extend HISE on the C++ side; scripts cannot substitute the alert window style through this flag alone.
> With this enabled, nothing styles the alert windows until your own code installs a replacement, so confirm dialogs will fall back to the default JUCE appearance.

**See also:** $API.ScriptLookAndFeel$ -- scripted look and feel is no longer consulted for alert windows when the project provides its own override

### `HISE_USE_MOUSE_WHEEL_FOR_TABLE_CURVE`

Legacy default that lets the mouse wheel adjust the curve tension on every table editor.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Sets the initial value of the useMouseWheelForCurve property on every table editor in the project so the mouse wheel bends the curve between two points instead of scrolling the parent viewport. The property is also exposed per instance in HISEScript, so the preprocessor only controls the starting value for components that have not overridden it. Leave this at the default unless you are maintaining a project built against older HISE versions where the mouse wheel always adjusted the curve.
> Prefer setting the useMouseWheelForCurve property on individual table components instead, because flipping this globally hijacks the scroll wheel for every table in the interface.

**See also:** $UI.Components.ScriptTable$ -- provides the default for the component's useMouseWheelForCurve property

### `HISE_USE_OPENGL_FOR_PLUGIN`

Compiles OpenGL rendering support into the plugin so the user can enable hardware-accelerated drawing.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Links the JUCE OpenGL code paths into the build and exposes the Open GL toggle in the settings window, which routes the interface rendering through the GPU instead of the CPU rasteriser. This is a significant quality-of-life improvement for large interfaces with animated panels or vector graphics, but adds a graphics driver dependency and a few megabytes to the binary, and can trigger driver-specific issues on older Windows GPUs. With the flag off, the toggle is absent and the plugin always draws through the software renderer regardless of the companion default value.
> Must be set consistently in both the HISE build and the exported plugin. On iOS OpenGL support is always present regardless of this flag.

**See also:** $PP.HISE_DEFAULT_OPENGL_VALUE$ -- selects whether OpenGL starts on or off when the user launches the plugin for the first time, $API.Settings.isOpenGLEnabled$ -- Settings.isOpenGLEnabled reports the active renderer state only when this integration is compiled in

### `HI_ENABLE_EXTERNAL_CUSTOM_TILES`

Enables a registration hook for custom floating tile panel types supplied in C++.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

Activates the REGISTER_EXTERNAL_FLOATING_TILE macro and the registerExternalPanelTypes hook, so a project that subclasses HISE on the C++ side can add its own panel types to the floating tile factory and make them available as ContentType options in the interface. With the flag off, the registration hook compiles out and only the built-in panel types are offered. Only relevant for custom HISE builds; projects that stay inside the scripting API never need to touch this.

**See also:** $API.ScriptFloatingTile$ -- custom panel types registered through this hook become available as ContentType options on a script floating tile

### `USE_LATO_AS_DEFAULT`

Uses the bundled Lato typeface as the default system font throughout the interface.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Selects which embedded typeface HISE binds to the GLOBAL_FONT and GLOBAL_BOLD_FONT macros and to the Linux font handler, so every label, popup, combobox and debug console picks it up unless a script explicitly overrides the font. The default since mid-2019 has been Lato Regular and Lato Bold, which read better at small sizes and ship with a wider glyph coverage. Setting this to 0 reverts to the older Oxygen typeface that shipped with early HISE releases, which is only useful for maintaining visual consistency with a project that was laid out against Oxygen metrics.
> Oxygen and Lato have different x-heights and advance widths, so flipping this in an existing project will reflow every label that uses the global font.

### `USE_SPLASH_SCREEN`

Shows a SplashScreen image while the standalone app loads its samples in the background.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | yes |

When enabled, the standalone build of the exported plugin displays a bundled splash bitmap (SplashScreen.png for desktop and iPad, SplashScreeniPhone.png for iPhone) while the plugin loads its sample content and initialises the audio engine. The image has to be present in the project's Images folder for the embed to pick it up; without it the plugin will fail to compile. Only affects standalone targets, because plugin windows in a DAW do not present a splash screen. The HISE export dialog writes this flag automatically from the 'Use Splash Screen' project setting.
> Only meaningful for standalone iOS and desktop exports. Regular VST, AU and AAX builds never display the splash image regardless of this flag.

## Deprecated

These macros are still defined so old projects keep compiling, but no code reads them. Setting them has no effect.

### `INCLUDE_BIG_SCRIPTNODE_OBJECT_COMPILATION`

Historical switch for excluding large scriptnode template instantiations from the build.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

The original purpose was to skip the bigger multi-template scriptnode objects during compilation so that iterative debug builds finished faster. The macro is still defined but no code reads it anywhere, so setting it has no effect on the build output or the runtime. It's kept around to avoid breaking user projects that still list it in their ExtraDefinitions.
