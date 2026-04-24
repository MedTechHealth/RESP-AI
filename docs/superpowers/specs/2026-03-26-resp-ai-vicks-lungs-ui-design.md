# Resp-AI UI Design Specification: "Vicks & Lungs" Overhaul

**Date:** 2026-03-26  
**Status:** Approved  
**Priority:** High  

## Overview

This document specifies the complete visual redesign of the Resp-Ai Flutter application to create a modern, medical-trustworthy UI with a "wow" factor that delivers identical, smooth performance across all platforms (Android, iOS, macOS, Linux, Windows) and all screen sizes.

The design implements the **"Advanced Bento" approach** with integrated **"Clinical Pulsar"** elements, centered around the Vicks VapoRub color palette and respiratory/lungs theme. It incorporates medical UI best practices to build trust through clarity, precision, and appropriate feedback mechanisms.

## Design Direction: Advanced Bento with Pulsar Elements

### Core Concept
A responsive "Bento Box" layout using glass-morphism ("Vapo-Glass") cards that intelligently rearrange based on screen real-estate. The primary interaction element is an interactive, amplitude-responsive "Living Lung" visualization that serves as both the capture button and a real-time biofeedback display.

### Visual Language
- **Primary Palette:** Deep Vicks Blue (#003366), Menthol Cyan (#00C6B5), Clinical Parchment (#F5F0E6), Clinical Amber (#FFB800)
- **Typography:** Fraunces for display/headlines, DM Sans for body/UI
- **Materials:** Glass-morphic surfaces with subtle menthol-tinted blurs, parchment backgrounds
- **Motion:** Fluid, physics-based animations using `flutter_animate`; micro-interactions on all touch targets
- **Medical Trustworthiness Elements:** 
  *   Clear visual hierarchy with important medical information prioritized
  *   Data visualization following clinical display best practices (minimal chartjunk, clear labels)
  *   Appropriate use of color for status (following medical alert standards: blue=info, cyan=active, amber=warning, red=error)
  *   Whitespace and reduction of cognitive load to support use in stressful situations

## Platform & Responsiveness Strategy

### Adaptive Layout System
1.  **Breakpoints (Defined in `breakpoints.dart`):**
    *   `mobile`: < 600px (Phones)
    *   `tablet`: 600px - 1024px (Tablets, small laptops)
    *   `desktop`: > 1024px (Laptops, desktops, large screens)

2.  **Layout Variations:**
    *   **Mobile (Portrait):** Vertical stack. Lung (Capture) card is prominent and top-most. Status and telemetry cards flow below.
    *   **Mobile (Lung Landscape):** Wider layout; Status card moves beside Capture card for better use of horizontal space.
    *   **Tablet:** Three-column layout. Nav Rail (optional) or top AppBar. Columns: [Status | Capture & Telemetry (vertical) | Sample Management].
    *   **Desktop/Wide:** Three-column layout with Navigation Rail. Columns: [Nav Rail | Status & Telemetry (vertical) | Capture (large, prominent) | Sample Management].

### Performance Optimization for Cross-Platform Consistency
*   **Rendering:** Utilize `RepaintBoundary` around expensive animations (the Lung visualization) to prevent unnecessary repaints of static UI.
*   **State Management:** Leverage `flutter_riverpod` with `select()` to minimize rebuilds to only the widgets that depend on changed state (e.g., amplitude, recording status).
*   **Asset Loading:** Use `flutter_svg` for scalable lung/icon assets; precache critical animations.
*   **Blur Performance:** Apply `ImageFilter.blur` sparingly and only on non-animating surfaces (cards). Use `const` where possible for decorations.
*   **Frame Budget:** Target 16ms per frame (60 FPS) on all devices. Profile regularly with `flutter profile`.

### Dark Mode & System Adaptation
*   **System Theme Respect:** The app follows system light/dark mode preferences via `ThemeMode.system`.
*   **Dark Palette:** Uses the inverted Vicks palette: Deep background (#001A33), Parchment becomes soft gray, Menthol Cyan retains vibrancy for visibility.
*   **Contrast Maintenance:** All UI elements maintain WCAG AA contrast ratios in both light and dark modes.
*   **Reduced Motion:** Respects system accessibility settings for reduced animation preferences.

## Component Breakdown

### 1. Living Lung Visualization (Core Widget)
*   **Purpose:** Primary capture button + real-time biofeedback display.
*   **Implementation:**
    *   SVG path of simplified, anatomical lungs.
    *   Stroke color: Menthol Cyan, animated via `AnimatedBuilder`.
    *   Stroke width/dash offset pulsates with microphone amplitude (0.0 - 1.0 range).
    *   On press (if not recording/analyzing): triggers `_toggleRecording()`.
    *   Displays recording duration as text overlay when active.
    *   Wrapped in `GestureDetector` + `RepaintBoundary`.
*   **Performance:** Stroke animation is lightweight; only the lung's path is repainted.

### 2. Vapo-Glass Card (Reusable Container)
*   **Purpose:** Consistent container for all informational/control panels.
*   **Implementation (`modern_glass_card.dart`):**
    *   Base: `Container` with `BoxDecoration`.
    *   `color`: `Colors.white.withValues(alpha: 0.6)` (adjustable opacity).
    *   `borderRadius`: `BorderRadius.circular(24)` (consistent radius).
    *   `border`: `BorderSide(color: AppTheme.glassBorder, width: 0.5)`.
    *   `boxShadow`: `AppTheme.panelShadow` (subtle, lifted effect).
    *   Optional: `BackdropFilter.blur(sigmaX: 10, sigmaY: 10)` for true glass (performance-tested).
*   **Usage:** Wraps all major UI sections (Capture, Status, Telemetry, etc.).

### 3. Responsive Layout Scaffold
*   **Purpose:** Manages AppBar/Navigation Rail and layout logic based on breakpoints.
*   **Implementation (`responsive_layout.dart`):**
    *   Uses `LayoutBuilder` to get constraints.
    *   Determines `breakpoint` (mobile/tablet/desktop).
    *   For `desktop`:
        *   `Scaffold` with `body: Row(children: [NavigationRail, Expanded(VerticalLayout)])`.
        *   `NavigationRail` displays icons for Status, Capture, Telemetry, Sample.
        *   Selected rail item highlights the corresponding column in the `VerticalLayout`.
    *   For `tablet`/`mobile`:
        *   `Scaffold` with `appBar: ResponsiveAppBar` and `body: VerticalLayout`.
        *   `ResponsiveAppBar` shows title and action icons (refresh).

### 4. Telemetry & Status Panels
*   **Purpose:** Display system state, duration, amplitude, and logs.
*   **Implementation:** Uses `_buildTelemetryTile` and `_buildStatusPanel` widgets from current code, enhanced with:
    *   Consistent Vapo-Glass card container.
    *   Animated value changes (e.g., duration counting up, amplitude bar).
    *   Color-coded status indicators (Recording=Oxide, Analyzing=Menthol Cyan, Ready=Vicks Blue).

### 5. Clinical Protocol & Sample Management Cards
*   **Purpose:** Guide user through the process and manage audio samples.
*   **Implementation:** Refactors current `_buildCompactProtocolCard` and `_buildSampleManagementCard` into Vapo-Glass cards with:
    *   Improved typography hierarchy.
    *   Clear, animated step indicators.
    *   Intuitive file picker and action buttons.

## Interaction & Micro-Interactions
*   **Buttons:** All buttons use `flutter_animate` for:
    *   `onPressed`: Scale down to 0.95, then spring back.
    *   `onLongPress`: Slight rotation + pulse.
    *   `onHover` (Desktop): Gentle elevation change and color shift.
*   **Transitions:** Page transitions (Home -> Result) use a shared-axis fade/slide.
*   **Feedback:** Subtle haptic feedback (`HapticFeedback.lightImpact()`) on successful capture start/stop.
*   **Error States:** 
    *   Permission denials show clear, actionable explanations with retry options
    *   Network/API errors display retry mechanisms with exponential backoff
    *   Processing errors show informative messages with suggested next steps
    *   All error states use AppTheme.oxide for clear visual distinction
*   **Loading/Skeleton States:**
    *   Skeleton screens shown during initial asset loading
    *   Micro-interactions indicate ongoing processes (pulsing, spinning)
    *   Progressive disclosure shows information as it becomes available

## Accessibility & Internationalization
*   **Text Scaling:** Respects system text scaling factors via `MediaQuery.textScaleFactor`.
*   **Touch Targets:** All interactive elements meet 48x48dp minimum.
*   **Contrast:** All text/background combinations meet WCAG AA contrast ratios.
*   **Labels:** All icons have semantic labels via `Tooltip` or embedded in accessibility tree.
*   **i11n:** All strings extracted for localization (using `intl` package, though current scope is English-only).

## Delivered Files (New/Modified)
*   **New:**
    *   `lib/widgets/living_lung_visualization.dart`
    *   `lib/widgets/vapo_glass_card.dart`
    *   `lib/layout/responsive_layout.dart`
    *   `lib/theme/vapo_glass_theme.dart` (extensions to `AppTheme`)
*   **Modified:**
    *   `lib/screens/home_screen.dart` (major refactor to use new components/layout)
    *   `lib/theme/app_theme.dart` (refine colors, add glass border constants)
    *   `lib/constants/breakpoints.dart` (ensure values are optimal)
    *   `lib/main.dart` (no change needed, structure is sound)

## Success Criteria
1.  **Visual Fidelity:** UI appears identical (±2dp) on Android, iOS, macOS, Linux, Windows at equivalent breakpoints.
2.  **Performance:** Maintains ≥55 FPS (target 60 FPS) on mid-tier devices from 2020+ (e.g., Snapdragon 7 Gen 2, A13 Bionic, Intel i5-10th gen).
3.  **Responsiveness:** Layout transitions smoothly at breakpoint changes without jank or visual pop.
4.  **Medical Trustworthiness:** UI conveys precision, cleanliness, and technological sophistication through restraint and purposeful motion, following clinical display best practices.
5.  **Wow Factor:** The Living Lung visualization provides delightful, informative feedback that encourages user engagement.

## Validation & Testing Procedures
To ensure the specification is correctly implemented:

*   **Visual Fidelity Testing:**
    *   Use automated screenshot comparison tools (like Flutter Goldens) across all target platforms
    *   Manual verification on physical devices representing each platform tier
    *   Verify layout consistency at breakpoint transitions

*   **Performance Testing:**
    *   Profile with `flutter profile` on benchmark devices (mid-tier 2020+)
    *   Monitor frame times using `flutter run --profile`
    *   Test animation jank prevention with Flutter DevTools

*   **Responsiveness Testing:**
    *   Test layout transitions at exact breakpoint widths
    *   Verify orientation changes maintain state and UI integrity
    *   Test on foldable devices and multi-window scenarios where applicable

*   **Accessibility Validation:**
    *   Verify WCAG AA contrast ratios with automated tools
    *   Test with screen readers (TalkBack, VoiceOver)
    *   Confirm respect for system text scaling and reduced motion settings

*   **Medical Usability Testing:**
    *   Conduct informal testing with target user group (if available)
    *   Verify clarity of status indicators and error messages
    *   Ensure interaction flow matches clinical workflow expectations

---
*Approved by: AI Design Review*  
*Next Step: Invoke `writing-plans` to create implementation plan*