# WellnessConnect Design System

## Overview
This document defines the design system for the WellnessConnect platform to ensure consistency across all pages and components.

**Last Updated**: 2025-10-05  
**Status**: ✅ Active  
**Version**: 1.0.0

---

## Color Palette

### Primary Colors - Teal/White/Gray Theme

#### Teal (Primary Accent)
- **teal-600**: `#0d9488` - **PRIMARY BRAND COLOR** - Buttons, links, icons, CTAs
- **teal-500**: `#14b8a6` - Gradient stops, hover states
- **teal-400**: `#2dd4bf` - Hover states on dark backgrounds, icons
- **teal-50**: `#f0fdfa` - Hover backgrounds, light accents

#### Gray (Neutral)
- **gray-900**: `#111827` - **PRIMARY DARK** - Footer, dark sections, primary text
- **gray-700**: `#374151` - **SECONDARY BRAND COLOR** - Gradient stops, text
- **gray-600**: `#4b5563` - Secondary text
- **gray-300**: `#d1d5db` - Secondary text on dark backgrounds
- **gray-200**: `#e5e7eb` - Borders, dividers
- **white**: `#ffffff` - Backgrounds, text on dark

---

## Component Patterns

### Buttons
**Primary CTA**: `bg-gradient-to-r from-teal-600 to-gray-700 hover:from-teal-700 hover:to-gray-800 text-white px-6 py-2 rounded-lg font-semibold transition-all duration-200 shadow-md hover:shadow-lg`

**Secondary**: `text-gray-700 hover:text-teal-600 hover:bg-teal-50 px-6 py-2 rounded-lg font-medium transition-all duration-200`

### Links
**Standard**: `text-teal-600 hover:text-teal-700 transition-colors duration-200`

**Footer**: `text-gray-300 hover:text-teal-400 transition-colors duration-200`

### Cards
**Standard**: `bg-white rounded-xl shadow-lg hover:shadow-xl transition-shadow duration-200 p-6`

### Forms
**Input**: `w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent transition-all duration-200`

---

## Gradients

### Backgrounds
- **Primary**: `bg-gradient-to-r from-teal-600 to-gray-700`
- **Hero/Dark**: `bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900`
- **Image Overlay**: `bg-gradient-to-t from-gray-900/40 via-gray-900/10 to-transparent`

### Text
- **Primary**: `bg-gradient-to-r from-teal-600 to-gray-700 bg-clip-text text-transparent`
- **Light**: `bg-gradient-to-r from-teal-400 to-white bg-clip-text text-transparent`

---

## Accessibility

### Focus States
All interactive elements: `focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2`

### ARIA Labels
Required for all icons and interactive elements without visible text

### Color Contrast
- Normal text: Minimum 4.5:1
- Large text: Minimum 3:1
- Interactive elements: Minimum 3:1

### Touch Targets
Minimum 44px × 44px on mobile

---

## Responsive Breakpoints
- **sm**: ≥ 640px
- **md**: ≥ 768px
- **lg**: ≥ 1024px
- **xl**: ≥ 1280px

---

## Usage Guidelines

### Use Teal For:
- Primary CTAs and action buttons
- Links and interactive elements
- Brand elements (logo, headings)
- Hover states and focus indicators

### Use Gray For:
- Body text and content
- Backgrounds and containers
- Borders and dividers
- Gradient combinations with teal

### Use White For:
- Page backgrounds
- Card backgrounds
- Text on dark backgrounds

---

**Follow this design system for all new features to maintain consistency across the WellnessConnect platform.**
