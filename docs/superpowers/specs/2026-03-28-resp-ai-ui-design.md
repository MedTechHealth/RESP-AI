# Resp-AI UI Design Specification - Detailed Version

## Overview
This document outlines a highly detailed design specification for the Resp-AI application's user interface, aiming for a "10/10 extraordinary" and human-designed feel. The design prioritizes a clean, modern aesthetic with a singular "Vicks Vaprup" light theme, deeply integrated "lungs as a theme," and seamless, high-performance responsiveness across all device sizes. The core functionality revolves around a data-driven dashboard with an at-a-glance summary, utilizing a dynamic, interactive anatomical lung model as a visual filter. The intent is to create a unique, professional, and intuitive user experience that stands out.

## 1. Overall Aesthetic & Theme

*   **Vicks Vaprup Aesthetic - Light Theme Focus:**
    *   **Primary Colors:** The theme will be light-colored, dominated by cool, crisp tones.
        *   `vaprupMint` (`#D9F4F4`): The predominant background color, providing a clean and refreshing canvas.
        *   `vaprupTeal` (`#00C0A4`): Used for secondary actions, subtle highlights, and accentuating data points related to healthy or positive status.
        *   `vaprupBlue` (`#007BFF`): Reserved for primary call-to-actions, crucial interactive elements, and highlighting critical data or selected states.
        *   `vaprupDarkText` (`#2C3E50`): For primary text, ensuring high readability against light backgrounds.
        *   `vaprupLightText` (`#ECF0F1`): For text on darker interactive elements (e.g., buttons with `vaprupBlue` background).
    *   **Gradients:** Subtle, linear gradients (e.g., `vaprupBlue` to `vaprupTeal`) will be sparingly used for primary buttons, prominent headers, or within visual elements to add depth and a modern, ethereal glow, mimicking the clean feeling of vapor.
    *   **Shadows/Depth:** Minimal, soft, long-distance shadows (e.g., `BoxShadow` with blur radius ~20-30px, low opacity black) will be used to lift cards and interactive elements slightly from the background, creating a sense of layered depth without heaviness. This enhances the glassmorphism effect.
*   **Lungs as a Theme - Integrated Visual Language:** Beyond the anatomical model, the lungs theme will be subtly woven into the UI:
    *   **Iconography:** Custom icons (or LucideIcons used with specific colors/gradients) may feature abstract representations of airflow, breath cycles, or lung structures.
    *   **Background Patterns:** Extremely subtle, faint abstract patterns resembling air currents or alveoli may be integrated into background textures (even simpler than `MeshBackground`'s grid, perhaps just organic noise or a very low-opacity diffuse gradient).
    *   **Shape Language:** Rounded corners will be prevalent (e.g., `borderRadius: BorderRadius.circular(16-24)` for cards and buttons) to convey softness and approachability, reminiscent of biological forms.
*   **Animation Style: Minimalist and Understated:**
    *   **Purpose:** Animations will primarily serve to provide clear feedback on interaction, guide user attention, and enhance the professional feel without being distracting or frivolous.
    *   **Data Updates:** When data on the anatomical model or summary cards updates, transitions will be smooth cross-fades or subtle scale changes (e.g., `FadeTransition`, `ScaleTransition` with `duration: 300ms`, `curve: Curves.easeInOut`).
    *   **Interaction Feedback:** Hover/tap states for interactive elements (buttons, model regions) will use subtle color changes or gentle glows (e.g., `vaprupBlue` button subtly brightens) or a slight scale animation (e.g., `Transform.scale` from 1.0 to 1.02) to acknowledge user input.
    *   **Component Transitions:** Page transitions and module revelations will use fast, clean slides or fades.

## 2. Information Hierarchy: Data-Driven Dashboard with At-a-Glance Summary

The main dashboard will be a "Data-driven dashboard" prioritizing an "At-a-glance summary."
*   **Key Metrics Presentation:**
    *   **Primary Risk Score:** Will be the most prominent numeric display, potentially large typography with a color-coded indicator (e.g., `vaprupTeal` for low risk, `alertCoral` for high risk).
    *   **Top Diagnostic Finding:** A concise text label (e.g., "Acoustic Pattern: Asthma") with an associated confidence score or trend arrow (e.g., "Trend: Improving" with a small `LucideIcons.arrowUp` icon).
    *   **Status Indicators:** Small, circular or pill-shaped indicators for "Recording," "Analyzing," or "Ready" will use distinct background colors (`alertCoral`, `warningAmber`, `vaprupTeal` respectively) and minimalist animations (e.g., a subtle pulsating glow for "Recording" state).
*   **Drill-Down Pathways:**
    *   Summary cards or sections will be clearly clickable, indicated by subtle hover effects (e.g., slightly increased shadow, border change).
    *   Clicking will either expand a section in-place (e.g., `AnimatedSize` widget) or navigate to a dedicated detail screen (e.g., `MaterialPageRoute` with a smooth slide transition).

## 3. Lungs Theme Integration: Dynamic Anatomical Model

The "Dynamic Anatomical Model" will be the central and most visually compelling element.
*   **Visual Style:** A stylized 2D model (initially, with potential for 3D later) of the lungs, potentially translucent or X-ray like, using `vaprupMint` as the base, with internal structures outlined in `vaprupTeal` or `vaprupBlue`.
    *   It will be visually clean, simplified, and focus on key regions (lobes, main bronchi).
    *   Subtle internal gradients or a very faint "glowing" effect can give it a sense of vitality and depth.
*   **Activity Hotspots:**
    *   When data indicates a region of interest, that specific area on the model will subtly change color (e.g., from `vaprupTeal` to `alertCoral` for high risk), with a gentle, minimalist pulsing or glowing animation to draw attention.
    *   The "Minimalist and understated" animation style will be critical here, avoiding aggressive flashing.

## 4. Model Interaction: Model as a Visual Filter

The anatomical model's interaction as a "Visual Filter" will be fluid and responsive.
*   **Region Selection Feedback:** When a user clicks/taps a lung region:
    *   The selected region will highlight with a crisp outline or a subtle, solid color fill (e.g., `vaprupBlue`), with a quick, short `FadeTransition` or `ScaleTransition` (e.g., 100ms duration).
    *   A small, temporary indicator (e.g., a "pill" with the region name) might appear near the model or in a control area to confirm the selection.
*   **Filtered Data Panel Updates:** Simultaneously, other relevant data modules on the dashboard will:
    *   Visually respond with a minimalist transition, such as a subtle `FadeTransition` (`duration: 200ms`) as their content reloads or re-filters to display data specific to the selected lung region.
    *   A clear "Filtered by: [Selected Region]" label will appear near the filtered data modules.

## 5. Overall Layout Structure: Modular Grid Layout

The dashboard will utilize a highly flexible and adaptive "Modular grid layout."
*   **Responsiveness:** Leveraging Flutter's `ResponsiveFramework` and `LayoutBuilder` for breakpoints (e.g., Mobile: <600px, Tablet: 600-1200px, Desktop: >1200px).
*   **Module Design:** Each module (e.g., Dynamic Anatomical Model, Risk Score Card, Historical Trends Chart) will be self-contained within a `ModernGlassCard` or a similar clean, card-like container, adhering to the "Vicks Vaprup" aesthetic.
*   **Dynamic Arrangement:** The grid will dynamically adjust column counts and module sizes. For example:
    *   **Mobile:** Primarily a single-column layout, with modules stacked vertically.
    *   **Tablet:** Potentially a 2-column layout, with larger modules spanning multiple columns.
    *   **Desktop:** A 2 or 3-column layout, optimized for information density without sacrificing clarity.

## 6. Compact Screen View (Mobile/iOS/Android)

The "mobile-first" approach dictates a highly focused experience on compact screens.
*   **Layout:** A single-column, scrollable layout (using `SingleChildScrollView`).
*   **Module Prioritization:**
    1.  **Top Bar/Header:** Minimalist app bar with app title ("RESP-AI"), a subtle branding element (e.g., abstract lung icon), and the theme switcher (as designed).
    2.  **Dynamic Anatomical Model (Module 1):** A prominent, scaled-down interactive lung model at the top. This will be the immediate visual anchor. Its dimensions will be responsive (e.g., `FractionallySizedBox` for width, fixed aspect ratio).
    3.  **Primary Summary Card (Module 2):** Directly below the model, a `ModernGlassCard` displaying the most critical "at-a-glance" information (e.g., Risk Score prominently, with Acoustic Pattern and Confidence as secondary details).
    4.  **Primary Action Button (Module 3):** A single, clear call-to-action button (e.g., "Start New Analysis" or "Record Breath") taking full width, designed with the `vaprupBlue` primary color.
    5.  **Status/Log Card (Module 4):** A `ModernGlassCard` module for system messages and status updates, providing minimalist feedback without requiring dedicated full-screen logs.
*   **Navigation:** Minimalist navigation (e.g., a tab bar *only if* there are truly distinct top-level sections beyond the dashboard itself, otherwise relying on drill-down within the dashboard). The goal is to avoid clutter.

## 7. Large Screen Elaboration (Desktop/Tablet)

The "Expand and Reveal" strategy will be utilized for larger screens within the modular grid.
*   **Layout Expansion:**
    *   The single-column mobile layout will transition to a multi-column grid (e.g., 2-column for tablet, 2-3 columns for desktop) as screen width increases.
    *   The Dynamic Anatomical Model module will expand significantly, becoming a central, larger interactive element, potentially occupying a larger grid area (e.g., `grid-area: 1 / 1 / span 2 / span 2;`).
*   **Revealed Modules (Examples):** Additional data modules will appear in previously empty grid cells or expanded areas:
    *   **Historical Trends Chart:** A `ModernGlassCard` module displaying a minimalist line chart of historical risk scores or pattern occurrences over time, dynamically updating when a lung region is filtered.
    *   **Detailed Metrics/Filtered Data:** A module showing more granular data points related to the selected lung region, or expanded "at-a-glance" details.
    *   **Patient Profile/Context:** A module displaying relevant patient information (if applicable and non-PII for initial scope) or contextual details for the current analysis.
    *   **Action Panel:** A dedicated panel for secondary actions (e.g., "Load Sample," "Save Report," "Settings"), elegantly integrated into the grid.
*   **Responsive Scaling:** All text, icons, and interactive elements will scale appropriately to maintain readability and usability across the expanded layout.

## Visual References & Implementation Guidelines (Detailed)

*   **Color Palette (Detailed):**
    *   **Background:** `vaprupMint` (`#D9F4F4`)
    *   **Primary Active/Interactive:** `vaprupBlue` (`#007BFF`)
    *   **Secondary/Highlight:** `vaprupTeal` (`#00C0A4`)
    *   **Text/Icons (on light background):** `vaprupDarkText` (`#2C3E50`)
    *   **Text/Icons (on dark active elements):** `vaprupLightText` (`#ECF0F1`) or pure white (`#FFFFFF`)
    *   **Alert/Error:** `alertCoral` (`#F43F5E`)
    *   **Warning:** `warningAmber` (`#F59E0B`)
    *   **Success/Safe:** `safeGreen` (`#10B981`)
    *   **Gradients:** Use `LinearGradient` (e.g., `vaprupBlue` to `vaprupAccent`, which is `#1ABC9C`) for depth on primary elements.
*   **Typography Hierarchy:**
    *   `GoogleFonts.spaceGrotesk` for `displayLarge`, `displayMedium`, `titleLarge` (headlines, primary numbers).
    *   `GoogleFonts.inter` for `bodyLarge`, `bodyMedium`, `labelLarge` (body text, labels, secondary info).
    *   `GoogleFonts.jetBrainsMono` for `SYSTEM LOG` or any code-like displays to ensure monospaced clarity.
*   **Component Styling:**
    *   **Cards (`ModernGlassCard`):** Subtle transparency (`color.withAlpha((value * 255).round())`), soft border (`1px solid color.withAlpha()`), and the minimalist shadow effect. Corners `borderRadius: circular(16-24)`.
    *   **Buttons (`ElevatedButton`, `OutlinedButton`):** Fully rounded rectangles (`borderRadius: circular(16)`), with `vaprupBlue` for primary actions and `vaprupTeal` for secondary. Hover/active states to utilize subtle `vaprupBlue` or `vaprupTeal` glow effects.
    *   **Input Fields:** Clean, understated input fields with subtle borders and clear focus states.
*   **Interactivity (Detailed):**
    *   **Dynamic Anatomical Model:** Clickable regions should have a distinct, yet subtle, highlight on hover/tap (e.g., outline expands slightly or fills with `vaprupBlue.withAlpha((0.3 * 255).round())`).
    *   **Filtered Data Panels:** When filtering, the affected data panels will show a quick, elegant loading indicator (e.g., a minimalist linear progress indicator with `vaprupBlue` color) before the new data fades in.
*   **Accessibility:** Ensure high contrast ratios for text and interactive elements. Semantic structuring of content for screen readers.
*   **Performance:** Leverage `const` constructors, `RepaintBoundary`, and efficient widget rebuilding strategies (e.g., `Riverpod` `select` or `Consumer` widgets) to maintain 60fps+ animations and smooth scrolling, especially on lower-end devices.

This detailed specification provides a robust blueprint for developing an exceptional Resp-AI UI, ensuring a consistent vision from design to implementation across all platforms.
