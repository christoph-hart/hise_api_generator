---
title: Licensing & Expansions
description: Copy protection, activation, and storefront integrations — unlocker overlays, machine-id fingerprints, Beatport and MuseHub hooks, expansion packs.
---

Preprocessors in this category compile the copy protection, online activation and expansion subsystems into the plugin. They enable the built-in unlocker overlay, the scripting surface that drives custom registration UIs, offline activation codes, stable machine-id fingerprints and third-party storefront hooks for MuseHub or Beatport. They also gate the optional expansion pack system and the folders that the exported plugin creates on first launch. Set these once per product and leave them alone, because flipping them after a public release invalidates existing licences and installed content.

### `DONT_CREATE_EXPANSIONS_FOLDER`

Disables automatic creation of the Expansions subfolder in the application data directory.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

When an exported plugin boots for the first time it normally ensures an Expansions subfolder exists so the expansion handler has somewhere to discover installed content. Setting this flag to 1 suppresses that directory creation, which is useful for projects that either ship without any expansion support or use a bespoke install location managed outside of the plugin. The directory is not deleted if it already exists, only the creation step is skipped.
> Only meaningful when the expansion system is enabled, otherwise no folder would be created anyway.

**See also:** $PP.HISE_ENABLE_EXPANSIONS$ -- gates the expansion subsystem whose default folder this flag suppresses, $PP.DONT_CREATE_USER_PRESET_FOLDER$ -- sibling flag that suppresses the automatic user preset folder in the same way

### `HISE_ALLOW_OFFLINE_ACTIVATION`

Enables an offline activation path in the copy protection flow.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

When enabled the unlocker accepts an activation response file generated on a separate, internet-connected machine instead of performing a live server round trip. The end user requests a challenge from the plugin, submits it to the licence server through a browser, and loads the returned response back into the plugin to finalise registration. This is typically required for studio machines that are permanently offline.
> Only takes effect when copy protection is compiled in.

**See also:** $PP.USE_COPY_PROTECTION$ -- enables the licensing subsystem that this flag extends with an offline path, $API.Unlocker$ -- scripting surface that drives the activation flow affected by this flag

### `HISE_INCLUDE_UNLOCKER_OVERLAY`

Includes the built-in registration overlay UI for the copy protection flow.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

This overlay presents the licence entry dialog and activation status messages on top of the plugin interface whenever the copy protection state requires user input. Disabling it removes the default UI so a project can implement a fully custom registration screen using the script copy protection API. Projects that want the standard look without extra work should leave this enabled.
> Has no effect when copy protection is not compiled in.

**See also:** $PP.USE_COPY_PROTECTION$ -- provides the licensing state that this overlay visualises, $PP.USE_SCRIPT_COPY_PROTECTION$ -- alternative registration UI path used when the built-in overlay is disabled

### `HISE_USE_UNLOCKER_FOR_EXPANSIONS`

Routes expansion authorisation through the main plugin unlocker.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | yes | no |

When enabled each expansion checks its encryption key against the licence information held by the main unlocker instead of maintaining its own per-expansion key. This simplifies the activation flow for the end user because a single serial grants access to both the base plugin and its expansions. When disabled each expansion is protected by its own independent key stored in the expansion metadata.
> Ignored when the expansion subsystem is not compiled in.

**See also:** $PP.USE_COPY_PROTECTION$ -- provides the unlocker instance that expansions are routed through, $PP.HISE_ENABLE_EXPANSIONS$ -- gates the expansion subsystem whose authorisation path this flag redirects, $API.Unlocker$ -- licence object consulted for each expansion when this flag is set, $API.ExpansionHandler$ -- manages the expansions whose protection path is altered by this flag, $PP.HISE_USE_XML_FOR_HXI$ -- container format for the encrypted expansions that this authorisation path gates

### `HISE_USE_XML_FOR_HXI`

Stores encrypted expansion (.hxi) files as XML text instead of a compact binary value tree.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | yes | no |

Switches the container format used by the encrypted expansion workflow so that the resulting .hxi files are human-readable XML rather than the default compact value-tree binary. Binary is smaller and loads faster at runtime; XML is noticeably larger but lets you diff the contents during development and inspect what a given expansion actually ships. The format is chosen per-write, so existing binary expansions keep loading regardless of this flag; only newly encoded expansions pick up the change.
> Read at runtime, so changing it in the Extra Definitions and re-encoding an expansion is enough without rebuilding HISE itself.

**See also:** $API.ExpansionHandler$ -- encrypted expansion workflow driven by the expansion handler uses the format selected by this flag, $API.Expansion$ -- individual expansion objects serialise into the container format selected by this flag, $PP.HISE_ENABLE_EXPANSIONS$ -- only meaningful in builds that compile the expansion subsystem in, $PP.HISE_USE_UNLOCKER_FOR_EXPANSIONS$ -- companion flag that governs how encrypted expansions are authorised

### `JUCE_ALLOW_EXTERNAL_UNLOCK`

Allows third-party storefronts to unlock the plugin using their own licence tokens.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

When enabled the unlocker accepts activation tokens issued by external distribution platforms in addition to the built-in licence server. This is required when the plugin is sold through marketplaces such as MuseHub or Beatport, which manage activation through their own account systems. Disabling it restricts registration to the first-party licence flow only.
> Local guard is added at the top of the translation unit that consumes this flag.

**See also:** $PP.HISE_INCLUDE_MUSEHUB$ -- enables the MuseHub storefront whose external activation relies on this flag, $PP.HISE_INCLUDE_BEATPORT$ -- enables the Beatport storefront whose external activation relies on this flag, $API.Unlocker$ -- scripting surface that receives the external token accepted by this flag

### `JUCE_USE_BETTER_MACHINE_IDS`

Switches the machine identification to a more stable hardware fingerprint.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

The default machine identifier can change after OS reinstalls or hardware driver updates, which forces legitimate users to reactivate more often than necessary. Enabling this flag selects an alternative fingerprint that is more resilient to such changes while still uniquely identifying the host. Existing activations remain tied to the old identifier so this should be set before the first public release.
> Changing this value after a release will invalidate previously issued licences.

**See also:** $PP.USE_COPY_PROTECTION$ -- provides the licensing subsystem that consumes the machine identifier, $API.Unlocker$ -- exposes the machine identifier to scripts for activation messages

### `USE_COPY_PROTECTION`

Compiles the licence verification and activation subsystem into the plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | yes |

Enabling this flag links the unlocker, overlay, and server communication code that challenge the user for a licence key on first launch and persist the result for subsequent sessions. Without it the plugin starts in an always-authorised state and no registration UI is shown, which is appropriate for free or internal builds. The flag is substituted by the compile exporter so it can differ between development and release builds of the same project.
> Many downstream licensing flags are inert unless this is enabled.

**See also:** $PP.USE_SCRIPT_COPY_PROTECTION$ -- adds the scripting layer on top of this subsystem, $PP.HISE_INCLUDE_UNLOCKER_OVERLAY$ -- supplies the default registration UI for this subsystem, $PP.HISE_ALLOW_OFFLINE_ACTIVATION$ -- extends this subsystem with an offline activation path, $PP.JUCE_USE_BETTER_MACHINE_IDS$ -- controls the fingerprint used by this subsystem to identify the host, $API.Unlocker$ -- scripting surface exposed when this subsystem is compiled in

### `USE_SCRIPT_COPY_PROTECTION`

Exposes the copy protection flow to HISEScript for custom registration UIs.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `0` | no | no |

This flag forwards the licence state, challenge, and activation response through the scripting API so a project can present a fully custom registration screen instead of relying on the built-in overlay. It is typically paired with a bespoke interface that matches the plugin branding and handles purchase links or trial logic. The underlying licensing checks still run natively, only the presentation layer moves into script.
> Has no effect unless the licensing subsystem is also compiled in.

**See also:** $PP.USE_COPY_PROTECTION$ -- provides the underlying licensing state that this scripting layer exposes, $PP.HISE_INCLUDE_UNLOCKER_OVERLAY$ -- default UI path replaced by custom scripts when this flag is enabled, $API.Unlocker$ -- scripting object that surfaces the licence state enabled by this flag

## Deprecated

These macros are still defined so old projects keep compiling, but no code reads them. Setting them has no effect.

### `HISE_ENABLE_EXPANSIONS`

Compiles the expansion handler and related infrastructure into the plugin.

| Default | Hot Reload | Auto Config |
|---|---|---|
| `1` | no | no |

Expansions are optional content packs that can be loaded at runtime from a dedicated folder, each carrying their own samples, presets, and images. Turning this on activates the expansion handler so projects can enumerate, load, and protect expansion packs via the scripting API. Disabling it strips the related code paths and is appropriate for projects that ship as a single fixed instrument.
> The guard is applied locally in the build rather than through the existing compile-time infrastructure.

**See also:** $PP.HISE_USE_UNLOCKER_FOR_EXPANSIONS$ -- routes expansion protection through the main unlocker when expansions are active, $PP.DONT_CREATE_EXPANSIONS_FOLDER$ -- suppresses the default folder that this subsystem would otherwise create, $API.ExpansionHandler$ -- scripting entry point exposed only when this subsystem is compiled in, $API.Expansion$ -- represents a single pack managed by the subsystem this flag enables, $PP.HISE_USE_XML_FOR_HXI$ -- container format for encrypted expansions produced by this subsystem
