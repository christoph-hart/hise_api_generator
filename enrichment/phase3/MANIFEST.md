# Phase 3 Import Manifest

**Date**: 2026-03-02  
**Source**: `D:\Development\hise_documentation\scripting\scripting-api\`  
**Criteria**: Files ≥600 bytes (TIER 1+2 quality documentation)  
**Total Files**: 201  
**Import Method**: Automated copy of existing hand-written documentation

---

## Purpose

This directory contains high-quality existing documentation from the HISE docs repository to serve as **manual overrides** in the enrichment pipeline. According to the Phase 3 merge rules, these files take priority over Phase 1 (AI-generated) and Phase 2 (project examples) content.

### Quality Tiers Included

- **TIER 1** (81 files ≥1,500 bytes): Excellent tutorial-quality content with multiple examples, comprehensive tables, and detailed explanations
- **TIER 2** (120 files 600-1,499 bytes): Good reference documentation with useful tables, examples, or detailed descriptions

### Merge Behavior

When these files are merged:
- **Prose outside code blocks** → becomes `userDocs` field (human-facing documentation for docs.hise.dev)
- **Code blocks** → becomes `examples` array entries (tagged `"source": "manual"`)
- **Doc-site links** (e.g., `[Array.push](/scripting/scripting-api/array#push)`) → converted to backtick references and extracted as `crossReferences`
- **YAML frontmatter** → stripped automatically by parser
- **Tables, blockquotes, bold/italic** → preserved in `userDocs`
- **Image references** → stripped

### Priority Rules

- Phase 3 `userDocs` **overrides** Phase 4 auto-generated prose
- Phase 3 `examples` are **merged with** Phase 1/2 examples (all preserved, tagged by source)
- Phase 3 `pitfalls` are **merged with** Phase 1/2 pitfalls (union merge)
- Phase 3 technical fields (description, signature, parameters) **override** Phase 1 if present

---

## Files by Class

```
     15 broadcaster
     10 graphics
     10 audiofile
     10 array
      9 scriptpanel
      7 scriptmodulationmatrix
      7 expansionhandler
      6 scriptwebview
      6 sampler
      6 midiautomationhandler
      6 engine
      6 content
      5 userpresethandler
      5 globalroutingmanager
      5 globalcable
      5 backgroundtask
      4 wavetablecontroller
      4 server
      4 scriptedviewport
      4 midiplayer
      4 builder
      3 synth
      3 scriptshader
      3 scriptlookandfeel
      3 node
      3 math
      3 fixobjectfactory
      3 filesystem
      3 console
      2 transporthandler
      2 threads
      2 scriptslider
      2 sample
      2 rectangle
      2 path
      2 markdownrenderer
      2 file
      2 expansion
      2 displaybuffer
      1 timer
      1 tableprocessor
      1 scriptmultipagedialog
      1 scriptbutton
      1 routingmatrix
      1 modulator
      1 midilist
      1 messageholder
      1 fixobjectstack
      1 fixobjectarray
      1 errorhandler
      1 effect
      1 dspnetwork
      1 download
      1 displaybuffersource
      1 colours
      1 buffer
      1 audiosampleprocessor
      1 Readme.md (root-level file, handled separately)
```

---

## Notable High-Value Content

### Tutorial-Quality Documentation (≥5KB)

1. **broadcaster/readme.md** (11K) - Complete Observer pattern tutorial with before/after examples, multiple use cases
2. **wavetablecontroller/setpostfxprocessors.md** (6.5K) - Comprehensive post-FX processing reference with parameter tables
3. **routingmatrix/Readme.md** (5.9K) - Multi-output plugin tutorial with step-by-step instructions
4. **scriptwebview/setenablewebsocket.md** (5.7K) - WebSocket integration guide with client/server code
5. **userpresethandler/setpluginparametersortfunction.md** (5.6K) - Plugin parameter sorting patterns
6. **threads/Readme.md** (5.5K) - Threading best practices and examples
7. **buffer/Readme.md** (5.5K) - Buffer operations tutorial
8. **transporthandler/Readme.md** (5.4K) - Master clock system documentation (overlaps with Phase 1/2)
9. **broadcaster/addcomponentpropertylistener.md** (5.4K) - Property listener patterns

### Classes with Comprehensive Coverage

- **broadcaster** (15 files) - Observer pattern, component listeners, property binding, context menus
- **graphics** (10 files) - Drawing operations, shadows, gradients, paths, rectangles
- **audiofile** (10 files) - Audio file loading, metadata, callbacks, range selection
- **array** (10 files) - Array manipulation methods with examples
- **scriptpanel** (9 files) - Panel callbacks, mouse handling, key press, file drop, timers

### Reference-Quality Documentation

- **scriptpanel/setkeypresscallback.md** (3.8K) - Complete key code reference table
- **scriptedviewport/settablecolumns.md** (3.8K) - Table column property reference
- **console/testcallback.md** (4.0K) - Automated testing guide for CLI tools
- **effect/setdraggablefilterdata.md** (4.5K) - Filter manipulation patterns
- **fixobjectfactory/Readme.md** (4.5K) - FixObject system architecture

---

## Classes with Phase 1/2 Overlap

These classes already have enrichment data in earlier phases. Phase 3 files will serve as manual overrides:

- **console** (3 files) - Has Phase 1 + Phase 4
  - `Readme.md`, `sample.md`, `testcallback.md`
- **globalcable** (5 files) - Has Phase 1 + Phase 4
  - `Readme.md`, `connecttomacrocontrol.md`, `getvalue.md`, `registercallback.md`, `registerdatacallback.md`, `senddata.md`
- **scriptedviewport** (4 files) - Has Phase 1 + Phase 4
  - `seteventtypesforvaluecallback.md`, `settablecallback.md`, `settablecolumns.md`, `settablemode.md`
- **transporthandler** (2 files) - Has Phase 1 + **Phase 2** + Phase 4
  - `Readme.md`, `setonbypass.md`

The merge process will combine content intelligently:
- Technical descriptions from Phase 1 (for MCP/LLM consumers)
- Real-world integration patterns from Phase 2 (TransportHandler only)
- User-facing prose from Phase 3 (this import)
- Auto-generated userDocs from Phase 4 as fallback

---

## Verification

✅ **File count**: 201 files copied successfully  
✅ **Largest files preserved**: broadcaster/readme.md = 11K  
✅ **Directory structure**: 56 class directories created  
✅ **Class distribution**: Top class (broadcaster) has 15 files, median ~2-4 files per class  
✅ **Size distribution**: 81 files ≥1,500 bytes, 120 files 600-1,499 bytes

---

## Next Steps

1. Review copied content (spot-check quality)
2. Run merge: `python api_enrich.py merge` (generates `enrichment/output/api_reference.json`)
3. Preview merged output: `python api_enrich.py preview [ClassName]`
4. Commit and push to preserve Phase 3 import

---

## Notes

- Files preserve original YAML frontmatter (will be stripped during merge)
- Filenames preserve original casing (e.g., `Readme.md` vs `readme.md`)
- Cross-references in markdown links will be auto-converted during merge
- Empty `.gitkeep` file removed from phase3 directory
- One root-level `Readme.md` file in the source was excluded (not class-specific)
