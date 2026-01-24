# Phase 3 Design: Consensus Building & Validation

**Project**: Circuit Board Knowledge Extractor  
**Date**: 2026-01-24  
**Status**: Proposed Design  

## Overview
Phase 3 focuses on resolving conflicts between multiple OCR readings of the same component across different images. We will build a "Consensus Layer" using three specialized Fabric patterns and an orchestration script.

## 1. Fabric Patterns

### A. `component-consensus-builder`
**Goal**: Determine the canonical component name from a list of noisy variants.

*   **Input**:
    *   `variants`: List of strings (e.g., `["STM32F103", "STM32F1O3", "STM32F103"]`)
    *   `frequencies`: How often each variant appeared.
    *   `context`: (Optional) Nearby text or component type if known.
*   **System Prompt Strategy**:
    *   Act as an expert electronics engineer.
    *   Analyze the variants for common OCR errors (0 vs O, 1 vs I, etc.).
    *   Use internal knowledge of component naming conventions (e.g., STM32 naming rules).
    *   Output the single most likely correct string and a confidence score (0.0-1.0).
    *   Explain the reasoning (e.g., "Corrected 'O' to '0' based on standard microcontroller numbering").

### B. `ocr-error-detector`
**Goal**: Detect and flag specific, high-probability OCR artifacts in technical text.

*   **Input**: Single string or list of strings.
*   **System Prompt Strategy**:
    *   Focus purely on character-level analysis.
    *   Flag "impossible" sequences in technical parts (e.g., lowercase 'l' inside a numeric sequence, '5' vs 'S' confusion).
    *   Return a "suspicion score" and specific error flags.

### C. `technical-identifier-validator`
**Goal**: Verify if a resolved name is a valid, plausible electronic component.

*   **Input**: Candidate canonical name.
*   **System Prompt Strategy**:
    *   Check against regex-like patterns for common manufacturers (TI, ST, NXP, Vishay, etc.).
    *   Verify package codes if present (SOT-23, QFP).
    *   Classify the component (Microcontroller, Resistor, Capacitor, IC).
    *   Output: `is_valid` (boolean), `category`, `manufacturer_guess`.

## 2. Orchestration: `consensus-builder.sh`

**Workflow**:
1.  **Load Data**: Read `data/pass2/component-database.json`.
2.  **Iterate Groups**: For each `component_group` in the database:
    *   Construct a prompt payload containing the `variants` and `frequency`.
    *   **Call Pattern**: Pipe payload to `fabric -p component-consensus-builder`.
    *   **Parse Output**: Extract the canonical name and confidence.
    *   **Validation**: (Optional) Pipe result to `technical-identifier-validator` for a second opinion.
3.  **Generate Output**:
    *   Create `data/pass3/canonical-components.json`.
    *   Structure:
        ```json
        [
          {
            "id": "group_001",
            "canonical_name": "STM32F103C8T6",
            "confidence": 0.95,
            "category": "Microcontroller",
            "original_variants": [...],
            "reasoning": "..."
          }
        ]
        ```

## 3. Integration Plan

1.  Create the 3 system prompts in `fabric-custom-patterns/`.
2.  Develop `consensus-builder.sh` to handle the JSON processing (using `jq` for payload construction).
3.  Run on the existing `component-database.json` derived from the Salto Encoder images.
4.  Manual review of the `canonical-components.json` to tune the patterns.
