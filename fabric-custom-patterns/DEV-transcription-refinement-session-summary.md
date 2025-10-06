
# Transcription Refinement Workflow - Development Session Summary
**Date:** 2025-09-30  
**User:** fabiofalopes  
**Status:** Proof of concept - NOT WORKING RELIABLY

---

## What We Set Out to Do

Create an intelligent transcription refinement system that:
1. Takes raw voice transcriptions (from Whisper/Groq)
2. Automatically detects and corrects mistranscribed technical terms
3. Fixes formatting, punctuation, and obvious errors
4. **Preserves the exact content and meaning** - never changes what was said
5. Outputs clean, professional transcriptions ready for documentation/notes

### The Vision
A two-stage pipeline using Fabric patterns:
- **Stage 1 (Analyzer):** Detect technical terms, acronyms, proper nouns that were mistranscribed
- **Stage 2 (Refiner):** Apply corrections, fix formatting, clean up transcription

### Target Use Case
- Voice notes about technical topics (software development, AI/ML, system configurations)
- Transcriptions often contain:
  - Technical terms transcribed phonetically ("react jay es" → "React.js")
  - Acronyms spelled out ("C I C D" → "CI/CD")
  - Tool/library names with spacing issues ("git hub" → "GitHub")
  - Poor formatting (run-on sentences, missing punctuation)

---

## What We Actually Built

### 1. Fabric Patterns (Prompts)
Created two custom Fabric patterns in: `~/Documents/Obsidian_Vault_01/Vault_01/fabric-custom-patterns/`

#### `transcript-analyzer/system.md`
- Analyzes raw transcription
- Identifies mistranscribed technical terms with 80%+ certainty
- Outputs a word list for the refiner to use

#### `transcript-refiner/system.md`
- Takes raw transcription + word list
- Fixes errors, applies corrections, adds formatting
- Preserves speaker's voice and content integrity

### 2. Shell Scripts

#### `transcribe-refine` (Main workflow script)
- Accepts input from stdin or clipboard
- Pipes through `fabric -p transcript-analyzer`
- Pipes through `fabric -p transcript-refiner`
- Outputs refined transcription and copies to clipboard

#### `vtranscribe` (Original full workflow - deprecated)
- Integrated with voice_note project
- Ran recording → transcription → refinement → JSON logging
- **Abandoned** because we wanted to separate concerns

#### Helper scripts
- `test-fabric` - Test fabric patterns
- `vtranscribe-logs` - View transcription logs (unused)

---

## What Actually Happened (Current State)

### **IT DOESN'T WORK AT ALL**

#### Problem 1: Wrong Output
The refiner is outputting **example text from the prompt** instead of processing the actual input.

**Example:**
- **Input:** 9792 characters about LLAMA server configuration, GPU settings, RPC inference
- **Output:** Example text about "React.js, TypeScript, GitHub Actions, CI/CD"

This is completely wrong. The model is regurgitating examples from the prompt instead of processing the real transcription.

#### Problem 2: Script Issues
The bash script might be mangling the input somehow:
- Variable escaping issues?
- Pipe problems?
- Fabric not receiving the full text?

#### Problem 3: Prompt Design
The prompts we created probably aren't clear enough or have too many examples that confuse the model.

#### Problem 4: Context Length
- We're trying to process large chunks of text (9792 chars in test case)
- Models might not be handling the full context
- Maybe need chunking strategy

---

## Key Insights & Learnings

### What Works
1. ✅ Fabric integration is functional (patterns load, commands run)
2. ✅ Voice note transcription works perfectly on its own
3. ✅ Basic piping mechanism works (clipboard → script)
4. ✅ The concept is sound - two-stage refinement makes sense

### What Doesn't Work
1. ❌ Prompts aren't effective - model outputs examples instead of processing input
2. ❌ No chunking strategy for large transcriptions
3. ❌ No validation that the output is actually different/better than input
4. ❌ No error handling for when model completely fails
5. ❌ Script might be corrupting input somewhere in the pipeline

### Critical Realizations

#### The Chunking Problem
- Raw transcriptions can be very long (thousands of characters)
- Can't reliably process entire transcription in one go
- Need to:
  1. Split text into manageable chunks
  2. Process each chunk
  3. Recombine intelligently
  4. Maybe use a third pass to ensure coherence

#### Token Efficiency Matters
- If we chunk properly, we can use free-tier models
- Can leverage bigger open-source models (70B+)
- Makes the system more accessible and faster

#### Fabric Ecosystem
- Fabric already has patterns for related tasks (tagging, summarization, etc.)
- We should leverage existing patterns instead of reinventing
- Maybe our patterns should be simpler and more focused

---

## Where We Are Now

### File Structure