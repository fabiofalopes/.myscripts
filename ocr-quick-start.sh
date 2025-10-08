#!/bin/bash

# Quick Start: Testing New OCR Patterns

cat << 'EOF'

╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║     Advanced OCR Patterns - Quick Start Guide                       ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 THE PROBLEM YOU IDENTIFIED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Cropped paragraph from low-res page → Works great
❌ Full low-res page with same paragraph → Fails

Why? Vision models have fixed visual token budgets. Full pages spread 
those tokens thin, dropping below the per-character resolution threshold.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛠️ THE SOLUTIONS CREATED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Two new patterns with aggressive prompt engineering:

1. ultra-ocr-engine
   • Maximum-effort extraction with contextual inference
   • Confidence ratings for uncertain text
   • Explicit low-resolution handling
   • Pattern completion for degraded characters

2. multi-scale-ocr
   • Hierarchical processing (MACRO → MESO → MICRO → SUB-PIXEL)
   • Context propagation from large to small text
   • Systematic region-by-region processing
   • Comprehensive quality reports

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 QUICK TEST (3 STEPS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1: Test ultra-ocr-engine on your problem image
───────────────────────────────────────────────────

  fabric -a your-lowres-page.jpg -p ultra-ocr-engine

  This pattern uses aggressive inference and reconstruction.
  Look for confidence ratings in the output.


Step 2: Test multi-scale-ocr for systematic extraction
───────────────────────────────────────────────────────

  fabric -a your-lowres-page.jpg -p multi-scale-ocr

  This pattern processes at multiple conceptual zoom levels.
  Check the comprehensive extraction report.


Step 3: Compare all patterns systematically
────────────────────────────────────────────

  ~/.myscripts/test-ocr-patterns.sh your-lowres-page.jpg

  This runs all 5 OCR patterns and generates a comparison report.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 WHAT TO LOOK FOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Compare the outputs:

  ✓ Did new patterns extract MORE text than standard patterns?
  ✓ Is the text extraction ACCURATE?
  ✓ Are confidence ratings helpful?
  ✓ Does multi-scale processing find text others missed?
  ✓ Is the output format usable for your needs?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📚 DOCUMENTATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Quick Summary:
  cat ~/.myscripts/docs/OCR-Solutions-Summary.md

Technical Analysis:
  cat ~/.myscripts/docs/OCR-Resolution-Challenge-Analysis.md

Pattern Details:
  cat ~/.myscripts/fabric-custom-patterns/ultra-ocr-engine/system.md
  cat ~/.myscripts/fabric-custom-patterns/multi-scale-ocr/system.md

Pattern Comparison:
  cat ~/.myscripts/fabric-custom-patterns/README.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 USAGE EXAMPLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Basic Usage:
────────────

  # Ultra OCR (aggressive extraction)
  fabric -a problem.jpg -p ultra-ocr-engine

  # Multi-scale OCR (hierarchical processing)
  fabric -a problem.jpg -p multi-scale-ocr


With Streaming (see progress):
───────────────────────────────

  fabric -a problem.jpg -p ultra-ocr-engine --stream


Save to File:
─────────────

  fabric -a problem.jpg -p ultra-ocr-engine -o output.md


With Specific Model:
────────────────────

  fabric -a problem.jpg -p ultra-ocr-engine -m gpt-4o


Batch Processing:
─────────────────

  for img in problem_docs/*.jpg; do
      fabric -a "$img" -p ultra-ocr-engine -o "results/$(basename $img .jpg).md"
  done


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 PATTERN SELECTION GUIDE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Image Quality          Recommended Pattern
────────────────────   ──────────────────────────────────────
High-res, clean        image-text-extraction (fast)
Technical IDs          expert-ocr-engine (accurate)
Programmatic use       analyze-image-json (structured)
Low-res/degraded       ultra-ocr-engine ⭐ (NEW - aggressive)
Full page low-res      multi-scale-ocr ⭐ (NEW - systematic)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 EXPECTED RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Best Case:
  • 20-40% more text extracted than standard patterns
  • Confidence ratings help identify uncertain extractions
  • Multi-scale processing finds text others miss

Realistic Case:
  • Noticeable improvement on problem images
  • May still struggle with very poor quality (<75 DPI)
  • Preprocessing may be needed for extreme cases

If Results Are Insufficient:
  • Next step: Implement image preprocessing (upscaling, enhancement)
  • Consider hybrid approach (Tesseract + VLM)
  • May need to request higher quality source images

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚦 NEXT ACTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Test on your actual problem images
2. Run comparison test: ./test-ocr-patterns.sh your-image.jpg
3. Evaluate improvement
4. Report back on effectiveness

If patterns work well:
  ✓ Use them in production
  ✓ Create workflows around them
  ✓ Consider creating custom variants for specific use cases

If patterns need more help:
  ⚠ Implement preprocessing (next phase)
  ⚠ Consider hybrid OCR approach
  ⚠ Evaluate if re-scanning is viable

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ready to test? Run this command with your problem image:

  fabric -a your-image.jpg -p ultra-ocr-engine

Good luck! 🚀

EOF
