# Holographic Lung Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a 10/10 "wow factor" UI for RESP-AI using a Vicks-inspired "Parchment & Menthol" palette and a holographic 3D lung data visualization.

**Architecture:** Fixed-viewport Stage & Bento layout. GPU-accelerated lung viz using CustomPainter/Shaders. Purposeful display of disease patterns and confidence values.

**Tech Stack:** Flutter, Riverpod, CustomPainter, FragmentShaders, Fraunces/DM Sans.

---

### Task 1: Palette & Typography Overhaul (Parchment & Menthol)

**Files:**
- Modify: `app/lib/theme/app_theme.dart`
- Modify: `app/lib/widgets/modern_glass_card.dart`

- [ ] **Step 1: Implement "Vicks" Palette.**
    - Background: `#F5F0E6` (Parchment)
    - Primary Text: `#003366` (Deep Vicks Blue)
    - Accents: `#00C6B5` (Menthol Cyan)
    - Warning: `#FFB800` (Clinical Amber)
- [ ] **Step 2: Update ModernGlassCard.**
    - Hairline borders (0.5px) using Deep Blue with 0.1 alpha.
    - Frosted Acrylic effect (30px blur, higher surface opacity).
- [ ] **Step 3: Refine Typography.**
    - High-contrast headers.
    - Tabular figures for all confidence and timing metrics.
- [ ] **Step 4: Commit theme changes.**

### Task 2: Core Viz - Stylized Holographic Lung

**Files:**
- Create: `app/lib/widgets/holographic_lung.dart`
- Modify: `app/lib/widgets/breath_halo_button.dart` (to nest the lung viz)

- [ ] **Step 1: Implement Lung Geometry Painter.**
    - Draw stylized bronchial tree and 5 lung lobes using Paths.
- [ ] **Step 2: Add Particle Flow.**
    - Particles flow through pathways during recording (Menthol Cyan).
- [ ] **Step 3: Implement Disease Overlay Logic.**
    - 'Pneumonia': Glowing fog in lower lobes (Amber).
    - 'Asthma': Constricting bronchial lines with intensity pulse.
- [ ] **Step 4: Implement Confidence Diffusion.**
    - High confidence = Sharp lines.
    - Low confidence = Gaussian blur/noisy lines on the model.
- [ ] **Step 5: Wrap in RepaintBoundary and optimize for 60fps.**
- [ ] **Step 6: Commit holographic viz.**

### Task 3: Layout - "Clinical Instrument" Dashboard

**Files:**
- Modify: `app/lib/screens/home_screen.dart`
- Modify: `app/lib/screens/result_screen.dart`

- [x] **Step 1: Reconstruct HomeScreen Stage.**
    - Center the Holographic Lung as the primary instrument.
    - Morphing button remains the primary trigger.
- [x] **Step 2: Reconstruct ResultScreen Narrative.**
    - Center the "Diagnostic Lung" with active disease heat-map.
    - Display "CONDITION: [NAME]" and "CONFIDENCE: [VALUE]%" as massive, unmissable display text.
- [x] **Step 3: Layout Bento Rails.**
    - Clean, asymmetric tiles for stats, telemetry, and workflow.
    - Remove all scrolling; use `Expanded` and `ConstrainedBox` for a perfect viewport fit.
- [x] **Step 4: Commit UI overhaul.**

### Task 4: Final Polish & Audit

- [x] **Step 1: Performance Profiling.**
    - Ensure shader warmup and 60fps during capture.
- [x] **Step 2: Lint & Build Verification.**
- [x] **Step 3: Final 10/10 UI Audit.**
- [x] **Step 4: Final commit and verify all tests pass.**
