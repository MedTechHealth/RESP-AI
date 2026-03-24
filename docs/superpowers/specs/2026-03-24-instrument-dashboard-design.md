# Spec: RESP-AI "Instrument Dashboard" UI Overhaul
**Date:** 2026-03-24
**Topic:** UI/UX Transformation & Performance Optimization

## 1. Executive Summary
Transform the existing scrolling-based Flutter UI into a fixed-viewport, high-performance "Instrument Dashboard." The goal is a professional medical aesthetic with a "wow factor" reactive visualization, maintaining clinical utility and absolute performance.

## 2. Design Direction: "Clinical Editorial"
- **Tone:** A blend of Apple Health precision and High-End Medical Journaling.
- **Aesthetic:** "Frost & Slate"—frosted glass surfaces over a dynamic mesh background.
- **Typography:** 
    - Display/Headers: `Fraunces` (Serif, Elegant)
    - Data/UI: `DM Sans` or `Satoshi` equivalent (Clean, Technical)
    - Features: `FontFeature.tabularFigures()` for all real-time metrics.

## 3. Architecture & Components
### 3.1 Layout Strategy
- **Stage (Central 60%):** Houses the primary "Reactive Liquid Ripple" visualization and main action triggers.
- **Bento Side-Rail (40%):** Asymmetric grid tiles for telemetry, status, and workflow steps.
- **Fixed Viewport:** Constraints ensuring no scrolling on 1080p+ displays; responsive collapse for mobile with a single-column scroll fallback.

### 3.2 Key Components
- **Reactive Liquid Ripple:** `CustomPainter` with layered sine waves, reactive to audio amplitude during active sessions.
- **Frosted Glass Cards:** `BackdropFilter` (30px blur) with 0.5px high-contrast borders.
- **Signal Waveform:** Mini-real-time visualization in the Bento grid.

## 4. Performance & Technical Standards
- **Repaint Boundaries:** Applied to all high-motion canvas elements.
- **Riverpod Optimization:** Use `.select()` to prevent widget-wide rebuilds on state updates.
- **Animation Timing:** 600ms `easeOutQuart` for staggered reveals.
- **Safety:** HIPAA-compliant in-memory audio handling (existing architecture).

## 5. Implementation Roadmap
1.  **Foundation:** Update `AppTheme` with the Frost & Slate color palette and refined typography.
2.  **Core Component:** Implement the `ReactiveLiquidRipple` CustomPainter.
3.  **HomeScreen Overhaul:** Build the "Stage" and "Bento Side-Rail" architecture.
4.  **ResultScreen Refinement:** Match the new aesthetic with high-contrast data visualization.
5.  **Quality Gate:** Audit with `flutter analyze` and performance profiling.

## 6. Success Criteria
- Zero scrolling on standard desktop resolutions.
- Reactive "wow factor" visualization that feels medically precise.
- 60FPS performance on targeted devices.
- AAA Accessibility for contrast and typography.
