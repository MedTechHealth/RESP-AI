# Instrument Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the RESP-AI UI into a high-performance "Clinical Editorial" instrument dashboard with a reactive liquid ripple visualization and zero-scroll fixed viewport.

**Architecture:** Use a "Stage & Bento Grid" layout. The Stage houses high-motion visualizations, while the Bento grid organizes clinical data. Performance is optimized via RepaintBoundary and specific Riverpod selectors.

**Tech Stack:** Flutter, Riverpod, flutter_animate, lucide_icons, google_fonts.

---

### Task 1: Foundation - Theme & Glass Tokens

**Files:**
- Modify: `/home/joel/Resp-AI/app/lib/theme/app_theme.dart`
- Modify: `/home/joel/Resp-AI/app/lib/widgets/modern_glass_card.dart`

- [ ] **Step 1: Update AppTheme with "Frost & Slate" palette and modular type scale.**
- [ ] **Step 2: Refine ModernGlassCard with 30px blur and 0.5px borders.**
- [ ] **Step 3: Run flutter analyze to ensure theme changes are valid.**
- [ ] **Step 4: Commit foundation changes.**

### Task 2: Core Viz - Reactive Liquid Ripple Component

**Files:**
- Create: `/home/joel/Resp-AI/app/lib/widgets/reactive_liquid_ripple.dart`
- Modify: `/home/joel/Resp-AI/app/lib/widgets/breath_halo_button.dart` (to incorporate ripple)

- [x] **Step 1: Implement ReactiveLiquidRipple CustomPainter with sine-wave layers.**
- [x] **Step 2: Add amplitude sensitivity logic to the ripple distortion.**
- [x] **Step 3: Wrap the painter in RepaintBoundary for performance.**
- [x] **Step 4: Replace the existing halo in BreathHaloButton with the new ripple.**
- [x] **Step 5: Verify smooth 60fps animation during recording state.**
- [x] **Step 6: Commit core viz changes.**

### Task 3: Layout - HomeScreen "Instrument Dashboard" Stage

**Files:**
- Modify: `/home/joel/Resp-AI/app/lib/screens/home_screen.dart`

- [ ] **Step 1: Reconstruct HomeScreen layout to use a fixed Stage (60%) and Bento Side-Rail (40%).**
- [ ] **Step 2: Implement "Morphing" button style for capture control (Circle to RoundedRect).**
- [ ] **Step 3: Add responsive clamp() logic to ensure zero-scroll on 1080p+ viewports.**
- [ ] **Step 4: Audit performance with high-speed amplitude updates.**
- [ ] **Step 5: Commit HomeScreen overhaul.**

### Task 4: Layout - ResultScreen "Clinical Narrative"

**Files:**
- Modify: `/home/joel/Resp-AI/app/lib/screens/result_screen.dart`

- [ ] **Step 1: Update ResultScreen to the high-contrast "Clinical Editorial" aesthetic.**
- [ ] **Step 2: Refine the risk dial visualization with cleaner typography and tabular figures.**
- [ ] **Step 3: Reorganize evidence tiles into a high-density clinical grid.**
- [ ] **Step 4: Verify deep-link navigation and back-swipe behavior.**
- [ ] **Step 5: Commit ResultScreen overhaul.**

### Task 5: Final Quality Gate & Review

- [ ] **Step 1: Run comprehensive build and lint checks.**
- [ ] **Step 2: Perform accessibility audit (contrast, hit targets).**
- [ ] **Step 3: Final performance profile check.**
- [ ] **Step 4: Final project-wide commit.**
