# Resp-AI UI Design Specification

## Overview
This document outlines the design specification for the Resp-AI application's user interface, aiming for a "10/10 extraordinary" and human-designed feel. The design prioritizes a clean, modern aesthetic with a singular "Vicks Vaprup" light theme, deeply integrated "lungs as a theme," and seamless responsiveness across all device sizes. The core functionality revolves around a data-driven dashboard with an at-a-glance summary, utilizing a dynamic anatomical lung model as a visual filter.

## 1. Overall Aesthetic & Theme

*   **Vicks Vaprup Aesthetic:** The application will feature a singular, light-colored theme inspired by the "Vicks Vaprup" tone. This will primarily involve cool blues (`vaprupBlue`, `vaprupAccent`), refreshing teals (`vaprupTeal`), and crisp whites/light backgrounds (`vaprupMint`). Subtle accents of deeper blues and greens (`vaprupDarkText`) will be used for contrast and readability. The overall feel will be clean, professional, calming, and invigorating.
*   **Lungs as a Theme:** The core visual metaphor will be a "Dynamic Anatomical Model" of the lungs, integrated prominently into the dashboard.
*   **Animation Style:** "Minimalist and understated" animations will be employed throughout the UI. This means smooth, subtle changes in opacity or gentle shifts in position/scale for data updates and interaction feedback. Animations will be used sparingly to avoid distraction, ensuring elegance, conciseness, and high performance. Examples include subtle fades for data changes, and gentle pulses for interaction feedback, all contributing to a professional, high-performance feel.

## 2. Information Hierarchy: Data-Driven Dashboard with At-a-Glance Summary

The main dashboard will function as a "Data-driven dashboard" with an "At-a-glance summary" as its primary information hierarchy.
*   Key metrics and primary findings (e.g., latest risk score, top diagnostic finding, status) will be immediately visible upon viewing the dashboard.
*   Clear, intuitive pathways will be provided for users to "drill down" into more detailed information or historical data as needed, preventing cognitive overload and supporting rapid clinical assessment.

## 3. Lungs Theme Integration: Dynamic Anatomical Model

A "Dynamic Anatomical Model" of the lungs will be the central visual element on the dashboard. This model will be:
*   Interactive and informative, serving as more than just a decorative element.
*   Presented in a stylized, modern 2D or 3D form, consistent with the overall aesthetic.
*   Capable of visually changing or highlighting areas to represent data, such as "activity hotspots" or regions of interest identified by the analysis.

## 4. Model Interaction: Model as a Visual Filter

The primary interaction with the Dynamic Anatomical Model will be as a "Visual Filter."
*   Users will be able to click or tap on specific regions of the lung model (e.g., a particular lobe, a bronchus).
*   This action will dynamically filter other data panels and visualizations on the dashboard to display information relevant only to that selected region. This enables powerful contextual exploration and analysis without cluttering the main model.

## 5. Overall Layout Structure: Modular Grid Layout

The entire application dashboard will be built upon a "Modular grid layout."
*   This flexible structure will allow individual components (modules) to adapt and rearrange seamlessly based on available screen real estate.
*   Each key piece of information or functionality will reside within its own module, ensuring clarity and separation of concerns.
*   This approach guarantees a consistent, high-quality, and performant user experience across all devices and screen sizes (mobile, tablet, desktop).

## 6. Compact Screen View (Mobile/iOS/Android)

The design will follow a "mobile-first" approach, optimizing for limited screen space initially.
*   **Essential Modules:** The initial view on compact screens will prioritize "Core Model + Primary Summary + Action."
    *   A **prominent (but appropriately scaled) Dynamic Anatomical Model** will be central.
    *   The **most critical "at-a-glance" summary metric** (e.g., current Risk Score, primary diagnostic finding, or a clear "Normal" status) will be displayed clearly, often directly below or beside the model.
    *   A **single, primary action button** (e.g., "Start New Analysis," "View Full Report," "Record Breath") will be readily accessible.
*   **Navigation:** Other modules and detailed data will be accessible via intuitive scrolling within the vertical stack or via clear, minimalist navigation cues (e.g., a subtle bottom navigation bar for essential top-level navigation, but not for granular data display).

## 7. Large Screen Elaboration (Desktop/Tablet)

For larger screens, the layout will "Expand and Reveal" additional functionality and data.
*   The core modules from the compact screen will naturally expand and intelligently rearrange within the modular grid to fill the increased available space.
*   Additional, contextually relevant "at-a-glance" summary cards and filtered data panels will gracefully appear in adjacent grid areas. These might include:
    *   Historical trends or graphs related to the primary finding.
    *   Comparative analysis views (e.g., comparing current scan to previous ones).
    *   More detailed log views or system status panels.
    *   The Dynamic Anatomical Model will remain a central, appropriately scaled, and detailed element, with its filtering capabilities extending across all revealed data modules.

## Visual References & Implementation Guidelines

*   **Color Palette:** Use the `vaprupTheme` colors defined in `app_theme.dart`. Key colors include:
    *   `vaprupMint` (Light, cool background)
    *   `vaprupTeal` (Refreshing primary green)
    *   `vaprupBlue` (Crisp primary blue)
    *   `vaprupDarkText` (Dark text for contrast)
    *   Accent colors for highlights and interaction feedback will be derived from these, ensuring the minimalist animation style is maintained.
*   **Typography:** Maintain consistency with `GoogleFonts.spaceGrotesk` for headlines and `GoogleFonts.inter` for body text. Ensure optimal readability across various sizes and screen densities.
*   **Component Styling:**
    *   Embrace a "glassmorphism" aesthetic for cards and panels, similar to the existing `ModernGlassCard`, but refined to integrate perfectly with the "Vicks Vaprup" palette.
    *   Use subtle borders, drop shadows, and gradients to create a sense of depth and hierarchy without being overly busy.
*   **Interactivity:** Ensure all interactive elements provide clear, minimalist feedback on tap/hover, consistent with the chosen animation style.
*   **Performance:** All visual elements and animations must be highly optimized for smooth performance across all target platforms (cross-platform, native-feel).

This specification serves as the blueprint for creating a visually stunning, highly functional, and truly unique UI for Resp-AI.
