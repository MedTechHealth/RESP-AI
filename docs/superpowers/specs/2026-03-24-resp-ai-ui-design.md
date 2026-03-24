# Resp-AI Flutter UI Design Spec

## Objective
Elevate the Flutter experience from a generic glassmorphism demo into a trustworthy, high-clarity respiratory triage instrument that feels clinically serious, visually memorable, and easier to use on desktop and mobile.

## Research Findings
- The product promise is a real-time respiratory capture and risk assessment workflow, but the current UI leans on familiar 2024 AI tropes: indigo/cyan gradients, glass cards, all-caps labels, and dense card stacking.
- `app/lib/screens/home_screen.dart` is a large monolith that mixes orchestration logic, state transitions, and visual composition in one file.
- `app/lib/screens/result_screen.dart` presents data but lacks a stronger narrative hierarchy around urgency, confidence, interpretation, and next steps.
- `app/lib/theme/app_theme.dart` already uses Google Fonts, so the app can support a more deliberate type and color system without introducing a new dependency.

## Candidate Design Directions

### 1. Clinical Editorial Console (recommended)
- Tone: editorial, premium, calm, instrument-like.
- Strengths: balances trust, readability, and personality; suits medical triage; works well on mobile and desktop.
- Risks: requires restraint so it feels premium instead of decorative.

### 2. Lab Terminal Minimalism
- Tone: dark, operational, technical.
- Strengths: strong perceived seriousness and signal-focus.
- Risks: less approachable, weaker daylight readability, and easier to feel generic for AI products.

### 3. Soft Wellness Companion
- Tone: warm, gentle, reassuring.
- Strengths: approachable for consumer use.
- Risks: underplays the product’s diagnostic precision and can feel too casual for risk scoring.

## Chosen Direction
Use Clinical Editorial Console. The app should feel like a modern respiratory intake instrument: warm neutral surfaces, ink-heavy typography, controlled accent colors, and a signature “breath halo” recorder element that becomes the most memorable visual in the app.

## UX Goals
- Make the primary action obvious within 3 seconds.
- Clarify session state at all times: ready, recording, file selected, analyzing, completed, error.
- Reframe results as a clinical narrative instead of a loose card collage.
- Improve desktop composition while preserving reachability and clarity on smaller screens.

## Visual System

### Typography
- Display: `Fraunces` for section headlines and high-emphasis metrics.
- Body/UI: `DM Sans` for operational text and controls.
- Numeric emphasis: bold tabular-feeling presentation for timers and scores.

### Color Palette
- Background parchment: warm off-white instead of flat white.
- Primary ink: deep slate-brown for text.
- Respiratory teal: used for active states and calm clinical cues.
- Oxide coral: used for live capture and alert emphasis.
- Brass/gold accent: used sparingly for premium instrument details.
- Remove the current dominant indigo/cyan bias.

### Signature Element
- Recorder control becomes a layered radial halo inspired by a stethoscope dial and breath wave.
- Background uses subtle contour lines, grain, and soft radial washes rather than generic blurred blobs.

## Information Architecture

### Home Screen
1. Top navigation strip with product identity and session reset.
2. Hero area with clear mission statement and current system readiness.
3. Primary capture panel with live timer, breath halo action control, and file-upload alternative.
4. Secondary rail with workflow steps, supported input notes, and privacy posture.
5. Inline status panel for errors, progress, and selected file information.

### Result Screen
1. Risk headline with narrative summary.
2. Strong dial/score block and confidence statement.
3. Evidence grid: pattern match, condition association, anomalies, processing metadata.
4. Recommendation/next-step panel and research disclaimer.
5. Return action that preserves clarity and continuity.

## Architecture Plan
- Keep business logic in the existing home screen state flow, but decompose the visual layer into focused private builders and reusable widgets.
- Replace current background and glass card styling with a token-driven “editorial instrument” system.
- Add reusable widgets for shell chrome, section cards, stat rows, and the breath halo control.
- Keep navigation and backend/audio integrations unchanged.

## Accessibility and Interaction Rules
- All primary controls must maintain >= 44px tap targets.
- Use visible textual state plus color/icon redundancy for recording and analyzing states.
- Preserve high contrast across neutral surfaces.
- Keep motion purposeful and light; ensure reduced visual noise during analysis.

## Testing Strategy
- Widget tests for home screen hero/status copy and primary actions.
- Widget tests for result screen sections and narrative summary.
- Smoke test for app boot with `ProviderScope` and `MaterialApp`.
- Run `flutter test` and a desktop `flutter analyze` pass before completion.

## Risks and Mitigations
- Large screen files already contain logic + layout; mitigate by modularizing as part of the redesign instead of layering new UI on top.
- Heavy visual effects can hurt performance; prefer gradients, painters, and simple opacity/transform animation over expensive nested blur.
- Result payloads may omit some details; every new section should degrade gracefully with fallback copy.
