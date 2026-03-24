# Resp-AI UI Overhaul Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the Flutter UI into an exceptional clinical editorial interface while preserving existing respiratory capture and analysis flows.

**Architecture:** Keep current Riverpod state and service integrations, but refactor the presentation layer around a shared visual system, lighter reusable widgets, and clearer home/result information hierarchy. Use TDD for widget coverage before introducing the new UI.

**Tech Stack:** Flutter, Material 3, flutter_riverpod, flutter_animate, google_fonts, lucide_icons

---

### Task 1: Add failing widget coverage for the new UI contract

**Files:**
- Create: `app/test/widget/app_ui_smoke_test.dart`
- Test: `app/test/widget/app_ui_smoke_test.dart`

- [ ] **Step 1: Write the failing tests**
Create widget tests that expect the future UI copy and structure:
- Home screen contains `Respiratory intake instrument`
- Home screen contains `Begin live capture`
- Home screen contains `Upload sample`
- Result screen contains `Respiratory risk overview`
- Result screen contains `Confidence signal`

- [ ] **Step 2: Run test to verify it fails**
Run: `flutter test test/widget/app_ui_smoke_test.dart`
Expected: FAIL because those labels do not exist yet.

### Task 2: Establish the new visual system

**Files:**
- Modify: `app/lib/theme/app_theme.dart`
- Modify: `app/lib/widgets/mesh_background.dart`
- Modify: `app/lib/widgets/modern_glass_card.dart`

- [ ] **Step 1: Redefine theme tokens**
Introduce the new warm-neutral palette, typography pair, component shapes, and button styles.

- [ ] **Step 2: Replace generic mesh styling**
Convert the background into a calmer contour/instrument-inspired atmosphere.

- [ ] **Step 3: Refactor the surface card component**
Turn the current glass card into a reusable editorial panel surface with optional accents.

- [ ] **Step 4: Run widget tests**
Run: `flutter test test/widget/app_ui_smoke_test.dart`
Expected: may still fail until screens are updated.

### Task 3: Rebuild the home screen experience

**Files:**
- Modify: `app/lib/screens/home_screen.dart`
- Create (optional if needed): `app/lib/widgets/breath_halo_button.dart`
- Create (optional if needed): `app/lib/widgets/editorial_panel.dart`

- [ ] **Step 1: Preserve existing recording/analyze logic**
Keep the timer, WebSocket handling, file picker flow, and navigation intact.

- [ ] **Step 2: Replace the current layout**
Create a stronger hero, primary action zone, workflow rail, and clearer inline status treatment.

- [ ] **Step 3: Add the signature breath halo control**
Use painter- or layer-based visuals rather than heavy blur stacks.

- [ ] **Step 4: Run targeted tests**
Run: `flutter test test/widget/app_ui_smoke_test.dart`
Expected: home-screen assertions pass.

### Task 4: Rebuild result storytelling

**Files:**
- Modify: `app/lib/screens/result_screen.dart`

- [ ] **Step 1: Reframe the screen around a risk narrative**
Lead with summary, risk overview, and confidence.

- [ ] **Step 2: Reorganize supporting data**
Present condition match, anomalies, metadata, and disclaimer in a more intentional hierarchy.

- [ ] **Step 3: Ensure fallback copy**
Handle missing anomalies/disclaimers/details gracefully.

- [ ] **Step 4: Run targeted tests**
Run: `flutter test test/widget/app_ui_smoke_test.dart`
Expected: result-screen assertions pass.

### Task 5: Verify and polish

**Files:**
- Modify: any files touched above as needed

- [ ] **Step 1: Run full test suite**
Run: `flutter test`
Expected: PASS.

- [ ] **Step 2: Run analyzer**
Run: `flutter analyze`
Expected: no errors.

- [ ] **Step 3: Do final design polish pass**
Check spacing, contrast, motion restraint, fallback states, and tap targets.

- [ ] **Step 4: Request code review feedback**
Use a reviewer to check maintainability and accessibility of the final UI changes.
