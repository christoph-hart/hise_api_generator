@echo off
REM ============================================================================
REM  batchCreateMeta.bat - Full enriched API binary blob pipeline
REM
REM  This is the single entry point for regenerating XmlApi.h/.cpp from the
REM  enriched API data. It supersedes running batchCreate.bat alone, which only
REM  produces Doxygen XML (Step 1 of 5).
REM
REM  Prerequisites: Python 3.x, Doxygen on PATH
REM
REM  Steps:
REM    1. batchCreate.bat           - Run Doxygen, copy/rename XML
REM    2. api_enrich.py phase0      - Parse XML into base JSON
REM    3. api_enrich.py merge       - Merge all enrichment phases
REM    4. api_enrich.py filter-binary - Strip to autocomplete fields
REM    5. ApiValueTreeBuilder.exe   - Emit XmlApi.h + XmlApi.cpp
REM ============================================================================

echo === Step 1/5: Running Doxygen XML generation (batchCreate.bat) ===
call batchCreate.bat > NUL 2>&1
if %ERRORLEVEL% NEQ 0 ( echo FAILED at Step 1 & goto :END )

echo === Step 2/5: Phase 0 - Parsing XML to base JSON ===
python api_enrich.py phase0
if %ERRORLEVEL% NEQ 0 ( echo FAILED at Step 2 & goto :END )

echo === Step 3/5: Merging all enrichment phases ===
python api_enrich.py merge
if %ERRORLEVEL% NEQ 0 ( echo FAILED at Step 3 & goto :END )

echo === Step 4/5: Filtering for binary (autocomplete fields only) ===
python api_enrich.py filter-binary
if %ERRORLEVEL% NEQ 0 ( echo FAILED at Step 4 & goto :END )

echo === Step 5/5: Building C++ binary blob (XmlApi.h + XmlApi.cpp) ===
ApiValueTreeBuilder.exe enrichment\output\filtered_api.json "..\..\hi_scripting\scripting\api" XmlApi
if %ERRORLEVEL% NEQ 0 ( echo FAILED at Step 5 & goto :END )

echo === Done. XmlApi.h and XmlApi.cpp updated in hi_scripting\scripting\api\ ===

:END
