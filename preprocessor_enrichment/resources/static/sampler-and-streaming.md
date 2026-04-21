---
description: Streaming sampler backend and sample-installation UX — monolith access, preload threshold, release start, and SamplesNotInstalled overlay buttons.
---

Preprocessors in this category configure the streaming sampler backend and the sample-installation user experience in exported plugins. They pick between memory-mapped and file-handle-based monolith access, set the preload size above which a sample is loaded entirely into RAM, enable the release start feature with its editor and scripting API, control the install and locate buttons on the SamplesNotInstalled overlay, choose the folder versus file picker for the Relocate Samples action, and expose the Full Dynamics HLAC encoding option to end users. Most of these trade disk access patterns against memory footprint and against the sample archive size. The export dialog writes a couple of them from project settings, so the manual overrides mostly cover non-standard installer flows.
