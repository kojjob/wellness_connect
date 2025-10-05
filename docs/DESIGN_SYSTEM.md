# WellnessConnect Design System

## Overview

This document serves as the **single source of truth** for the WellnessConnect platform design system. It defines the complete visual language, component library, and implementation guidelines to ensure consistency across all pages and features.

**Last Updated**: 2025-10-05
**Status**: ✅ Active
**Version**: 1.0.0
**Theme**: Teal/White/Gray Healthcare Aesthetic

---

## Table of Contents

1. [Color Palette](#color-palette)
2. [Typography System](#typography-system)
3. [Spacing & Layout](#spacing--layout)
4. [Component Library](#component-library)
5. [Visual Effects](#visual-effects)
6. [Background Usage Guidelines](#background-usage-guidelines)
7. [Accessibility Standards](#accessibility-standards)
8. [Page-Specific Guidelines](#page-specific-guidelines)
9. [Usage Guidelines](#usage-guidelines)
10. [Maintenance & Updates](#maintenance--updates)

---

## Color Palette

### Primary Colors - Teal/White/Gray Theme

The WellnessConnect platform uses a professional healthcare color scheme centered around teal (representing trust, health, and calmness), gray (representing professionalism and stability), and white (representing cleanliness and clarity).

#### Teal Shades (Primary Accent)

| Tailwind Class | Hex Code | RGB | Usage |
|----------------|----------|-----|-------|
| `teal-50` | `#f0fdfa` | `rgb(240, 253, 250)` | Hover backgrounds, light accents, subtle highlights |
| `teal-100` | `#ccfbf1` | `rgb(204, 251, 241)` | Very light backgrounds, disabled states |
| `teal-200` | `#99f6e4` | `rgb(153, 246, 228)` | Section headings on dark backgrounds, light borders |
| `teal-400` | `#2dd4bf` | `rgb(45, 212, 191)` | **Hover states on dark backgrounds**, icons, badges |
| `teal-500` | `#14b8a6` | `rgb(20, 184, 166)` | Gradient stops, active states |
| `teal-600` | `#0d9488` | `rgb(13, 148, 136)` | **PRIMARY BRAND COLOR** - Buttons, links, icons, CTAs |
| `teal-700` | `#0f766e` | `rgb(15, 118, 110)` | Hover states on buttons, darker accents |

**Primary Brand Color**: `teal-600` (#0d9488) should be used for all primary interactive elements.

#### Gray Shades (Neutral)

| Tailwind Class | Hex Code | RGB | Usage |
|----------------|----------|-----|-------|
| `white` | `#ffffff` | `rgb(255, 255, 255)` | Page backgrounds, card backgrounds, text on dark |
| `gray-50` | `#f9fafb` | `rgb(249, 250, 251)` | Light section backgrounds, alternating rows |
| `gray-100` | `#f3f4f6` | `rgb(243, 244, 246)` | Card backgrounds, input backgrounds |
| `gray-200` | `#e5e7eb` | `rgb(229, 231, 235)` | Borders, dividers, disabled backgrounds |
| `gray-300` | `#d1d5db` | `rgb(209, 213, 219)` | Secondary text on dark backgrounds, placeholder text |
| `gray-400` | `#9ca3af` | `rgb(156, 163, 175)` | Placeholder text, disabled text, icons |
| `gray-600` | `#4b5563` | `rgb(75, 85, 99)` | Secondary text, labels |
| `gray-700` | `#374151` | `rgb(55, 65, 81)` | **SECONDARY BRAND COLOR** - Gradient stops, body text |
| `gray-800` | `#1f2937` | `rgb(31, 41, 55)` | Dark backgrounds, headings |
| `gray-900` | `#111827` | `rgb(17, 24, 39)` | **PRIMARY DARK** - Footer, dark sections, primary text |

**Primary Dark Color**: `gray-900` (#111827) should be used for dark backgrounds and footer sections.

#### Accent Colors (Semantic)

| Color | Tailwind Class | Hex Code | Usage |
|-------|----------------|----------|-------|
| **Success** | `green-500` | `#10b981` | Success messages, verified badges, positive indicators |
| **Success Hover** | `green-600` | `#059669` | Success button hover states |
| **Warning** | `yellow-500` | `#f59e0b` | Warning messages, attention indicators |
| **Warning Alt** | `amber-500` | `#f59e0b` | Alternative warning color |
| **Error** | `red-500` | `#ef4444` | Error messages, destructive actions |
| **Error Hover** | `red-600` | `#dc2626` | Error button hover, admin indicators |

### Color Contrast Ratios (WCAG 2.1 AA Compliance)

| Foreground | Background | Ratio | Pass |
|------------|------------|-------|------|
| `gray-900` | `white` | 16.1:1 | ✅ AAA |
| `gray-700` | `white` | 9.7:1 | ✅ AAA |
| `gray-600` | `white` | 7.2:1 | ✅ AAA |
| `teal-600` | `white` | 4.8:1 | ✅ AA |
| `white` | `teal-600` | 4.8:1 | ✅ AA |
| `white` | `gray-900` | 16.1:1 | ✅ AAA |
| `teal-400` | `gray-900` | 7.5:1 | ✅ AAA |
| `gray-300` | `gray-900` | 5.9:1 | ✅ AA |

---

## Typography System

### Font Families

```css
/* Primary Font (Sans-serif) */
font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
             "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;

/* Monospace Font (Code) */
font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,
             "Liberation Mono", "Courier New", monospace;
```

### Font Sizes

| Tailwind Class | Size (rem) | Size (px) | Line Height | Usage |
|----------------|------------|-----------|-------------|-------|
| `text-xs` | 0.75rem | 12px | 1rem | Small labels, badges, timestamps |
| `text-sm` | 0.875rem | 14px | 1.25rem | Body text, links, form labels |
| `text-base` | 1rem | 16px | 1.5rem | **Default body text**, paragraphs |
| `text-lg` | 1.125rem | 18px | 1.75rem | Large body text, emphasized content |
| `text-xl` | 1.25rem | 20px | 1.75rem | Section subheadings, card titles |
| `text-2xl` | 1.5rem | 24px | 2rem | Card headings, small section headings |
| `text-3xl` | 1.875rem | 30px | 2.25rem | Section headings, page subheadings |
| `text-4xl` | 2.25rem | 36px | 2.5rem | Page headings, major sections |
| `text-5xl` | 3rem | 48px | 1 | Hero headings, landing page titles |
| `text-6xl` | 3.75rem | 60px | 1 | Large hero headings, marketing pages |

### Font Weights

| Tailwind Class | Weight | Usage |
|----------------|--------|-------|
| `font-normal` | 400 | Body text, paragraphs |
| `font-medium` | 500 | Emphasized text, labels |
| `font-semibold` | 600 | **Subheadings, buttons**, form labels |
| `font-bold` | 700 | **Headings**, important text, CTAs |
| `font-extrabold` | 800 | Hero headings, major titles |

### Heading Hierarchy

```html
<!-- H1 - Page Title (Use once per page) -->
<h1 class="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
  Page Title
</h1>

<!-- H2 - Major Section Heading -->
<h2 class="text-3xl md:text-4xl font-bold text-gray-900 mb-3">
  Section Heading
</h2>

<!-- H3 - Subsection Heading -->
<h3 class="text-2xl md:text-3xl font-semibold text-gray-900 mb-2">
  Subsection Heading
</h3>

<!-- H4 - Card/Component Heading -->
<h4 class="text-xl md:text-2xl font-semibold text-gray-900 mb-2">
  Component Heading
</h4>

<!-- H5 - Small Heading -->
<h5 class="text-lg md:text-xl font-semibold text-gray-900 mb-1">
  Small Heading
</h5>

<!-- H6 - Tiny Heading -->
<h6 class="text-base md:text-lg font-semibold text-gray-900 mb-1">
  Tiny Heading
</h6>
```

### Text Styles

```html
<!-- Body Text -->
<p class="text-base text-gray-700 leading-relaxed">
  Standard paragraph text with comfortable line height.
</p>

<!-- Lead Text (Introductory paragraph) -->
<p class="text-lg text-gray-600 leading-relaxed">
  Larger introductory text for section openings.
</p>

<!-- Small Text -->
<p class="text-sm text-gray-600">
  Smaller text for captions, footnotes, or secondary information.
</p>

<!-- Muted Text -->
<p class="text-sm text-gray-500">
  Muted text for less important information.
</p>
```

---

## Spacing & Layout

### Spacing Scale

| Tailwind Class | Size (rem) | Size (px) | Common Usage |
|----------------|------------|-----------|--------------|
| `1` | 0.25rem | 4px | Tight spacing, icon gaps |
| `2` | 0.5rem | 8px | Small gaps, compact layouts |
| `3` | 0.75rem | 12px | Medium-small gaps |
| `4` | 1rem | 16px | **Standard spacing**, default gaps |
| `5` | 1.25rem | 20px | Medium spacing |
| `6` | 1.5rem | 24px | **Card padding**, comfortable spacing |
| `8` | 2rem | 32px | **Large spacing**, section gaps |
| `10` | 2.5rem | 40px | Extra large spacing |
| `12` | 3rem | 48px | **Section padding (mobile)** |
| `16` | 4rem | 64px | **Section padding (desktop)** |
| `20` | 5rem | 80px | Extra large section padding |
| `24` | 6rem | 96px | **Hero section padding** |

### Common Spacing Patterns

```css
/* Section Padding (Responsive) */
py-12 md:py-16 lg:py-24
/* Mobile: 48px, Tablet: 64px, Desktop: 96px */

/* Card Padding (Responsive) */
p-6 md:p-8
/* Mobile: 24px, Desktop: 32px */

/* Button Padding */
px-6 py-2
/* Horizontal: 24px, Vertical: 8px */

/* Input Padding */
px-4 py-2
/* Horizontal: 16px, Vertical: 8px */

/* Container Max Width */
max-w-7xl mx-auto px-4 sm:px-6 lg:px-8
/* Max width: 1280px, Responsive horizontal padding */

/* Grid Gap */
gap-6 md:gap-8 lg:gap-12
/* Mobile: 24px, Tablet: 32px, Desktop: 48px */
```

### Responsive Breakpoints

| Breakpoint | Min Width | Tailwind Prefix | Typical Usage |
|------------|-----------|-----------------|---------------|
| **Mobile** | < 640px | (default) | Single column, stacked layout |
| **Small** | ≥ 640px | `sm:` | Small tablets, large phones |
| **Medium** | ≥ 768px | `md:` | **Tablets, primary breakpoint** |
| **Large** | ≥ 1024px | `lg:` | **Desktops, laptops** |
| **Extra Large** | ≥ 1280px | `xl:` | Large desktops |
| **2X Large** | ≥ 1536px | `2xl:` | Very large screens |

### Container Widths

```css
/* Full Width Container */
<div class="w-full">

/* Centered Container with Max Width */
<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

/* Narrow Container (Forms, Articles) */
<div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">

/* Wide Container (Dashboards) */
<div class="max-w-screen-2xl mx-auto px-4 sm:px-6 lg:px-8">
```

### Grid Systems

```html
<!-- 2-Column Grid (Responsive) -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
  <!-- Content -->
</div>

<!-- 3-Column Grid (Responsive) -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  <!-- Content -->
</div>

<!-- 4-Column Grid (Responsive) -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
  <!-- Content -->
</div>

<!-- Auto-fit Grid (Flexible columns) -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
  <!-- Content -->
</div>
```

---

## Component Library

### Buttons

#### Primary Button (Gradient CTA)

```html
<button class="bg-gradient-to-r from-teal-600 to-gray-700 hover:from-teal-700 hover:to-gray-800 text-white px-6 py-2 rounded-lg text-sm font-semibold transition-all duration-200 shadow-md hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2">
  Primary Action
</button>
```

**Usage**: Main CTAs, form submissions, primary actions
**Example**: "Get Started", "Book Appointment", "Sign Up"

#### Secondary Button

```html
<button class="text-gray-700 hover:text-teal-600 hover:bg-teal-50 px-6 py-2 rounded-lg text-sm font-medium transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2">
  Secondary Action
</button>
```

**Usage**: Secondary actions, cancel buttons, alternative options
**Example**: "Learn More", "Cancel", "Go Back"

#### Outline Button

```html
<button class="border-2 border-teal-600 text-teal-600 hover:bg-teal-600 hover:text-white px-6 py-2 rounded-lg text-sm font-semibold transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2">
  Outline Action
</button>
```

**Usage**: Alternative CTAs, less prominent actions
**Example**: "View Details", "Download", "Share"

#### Disabled Button

```html
<button disabled class="bg-gray-300 text-gray-500 px-6 py-2 rounded-lg text-sm font-semibold cursor-not-allowed opacity-60">
  Disabled Action
</button>
```

**Usage**: Inactive or unavailable actions

#### Small Button

```html
<button class="bg-gradient-to-r from-teal-600 to-gray-700 hover:from-teal-700 hover:to-gray-800 text-white px-4 py-1.5 rounded-md text-xs font-semibold transition-all duration-200 shadow-sm hover:shadow-md">
  Small Action
</button>
```

**Usage**: Compact spaces, inline actions, table actions

#### Large Button

```html
<button class="bg-gradient-to-r from-teal-600 to-gray-700 hover:from-teal-700 hover:to-gray-800 text-white px-8 py-3 rounded-lg text-base font-bold transition-all duration-200 shadow-lg hover:shadow-xl">
  Large Action
</button>
```

**Usage**: Hero sections, major CTAs, landing pages

#### Icon Button

```html
<button class="p-2 text-gray-600 hover:text-teal-600 hover:bg-teal-50 rounded-full transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2" aria-label="Close">
  <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
    <!-- Icon path -->
  </svg>
</button>
```

**Usage**: Close buttons, icon-only actions, toolbar buttons

### Cards

#### Standard Card

```html
<div class="bg-white rounded-xl shadow-lg hover:shadow-xl transition-shadow duration-200 p-6">
  <h3 class="text-xl font-semibold text-gray-900 mb-2">Card Title</h3>
  <p class="text-gray-600">Card content goes here.</p>
</div>
```

**Usage**: Content containers, feature cards, information blocks

#### Card with Border

```html
<div class="bg-white rounded-xl shadow-md p-6 ring-1 ring-gray-200 hover:ring-teal-500 transition-all duration-200">
  <h3 class="text-xl font-semibold text-gray-900 mb-2">Card Title</h3>
  <p class="text-gray-600">Card content goes here.</p>
</div>
```

**Usage**: Selectable cards, interactive elements, form sections

#### Card with Gradient Border

```html
<div class="bg-white rounded-xl shadow-lg p-6 relative overflow-hidden">
  <div class="absolute inset-0 bg-gradient-to-r from-teal-600 to-gray-700 opacity-10"></div>
  <div class="relative z-10">
    <h3 class="text-xl font-semibold text-gray-900 mb-2">Card Title</h3>
    <p class="text-gray-600">Card content goes here.</p>
  </div>
</div>
```

**Usage**: Featured cards, premium content, highlighted sections

#### Card with Image

```html
<div class="bg-white rounded-xl shadow-lg overflow-hidden hover:shadow-xl transition-shadow duration-200">
  <div class="relative h-48">
    <img src="image.jpg" alt="Description" class="w-full h-full object-cover">
    <div class="absolute inset-0 bg-gradient-to-t from-gray-900/40 via-gray-900/10 to-transparent"></div>
  </div>
  <div class="p-6">
    <h3 class="text-xl font-semibold text-gray-900 mb-2">Card Title</h3>
    <p class="text-gray-600">Card content goes here.</p>
  </div>
</div>
```

**Usage**: Provider cards, service cards, blog posts

#### Testimonial Card

```html
<div class="bg-white rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow duration-200">
  <div class="flex items-center mb-4">
    <div class="h-12 w-12 rounded-full bg-gradient-to-br from-teal-500 to-gray-600 flex items-center justify-center text-white font-bold">
      JD
    </div>
    <div class="ml-4">
      <h4 class="text-base font-semibold text-gray-900">John Doe</h4>
      <p class="text-sm text-gray-600">Patient</p>
    </div>
  </div>
  <p class="text-gray-700 italic">"Testimonial text goes here..."</p>
  <div class="flex items-center mt-4">
    <!-- Star rating -->
    <div class="flex text-yellow-400">
      ★★★★★
    </div>
  </div>
</div>
```

**Usage**: Patient testimonials, reviews, feedback

### Forms

#### Text Input

```html
<div class="mb-4">
  <label for="input-id" class="block text-sm font-semibold text-gray-700 mb-2">
    Label Text
  </label>
  <input
    type="text"
    id="input-id"
    name="input-name"
    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent transition-all duration-200"
    placeholder="Enter text">
</div>
```

#### Text Input with Icon

```html
<div class="mb-4">
  <label for="email" class="block text-sm font-semibold text-gray-700 mb-2">
    Email Address
  </label>
  <div class="relative">
    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
      <svg class="h-5 w-5 text-gray-400" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
        <!-- Icon path -->
      </svg>
    </div>
    <input
      type="email"
      id="email"
      class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent transition-all duration-200"
      placeholder="you@example.com">
  </div>
</div>
```

#### Textarea

```html
<div class="mb-4">
  <label for="message" class="block text-sm font-semibold text-gray-700 mb-2">
    Message
  </label>
  <textarea
    id="message"
    name="message"
    rows="4"
    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent transition-all duration-200 resize-none"
    placeholder="Enter your message"></textarea>
</div>
```

#### Select Dropdown

```html
<div class="mb-4">
  <label for="select" class="block text-sm font-semibold text-gray-700 mb-2">
    Select Option
  </label>
  <select
    id="select"
    name="select"
    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent transition-all duration-200 bg-white">
    <option value="">Choose an option</option>
    <option value="1">Option 1</option>
    <option value="2">Option 2</option>
  </select>
</div>
```

#### Checkbox

```html
<div class="flex items-center mb-4">
  <input
    type="checkbox"
    id="checkbox"
    name="checkbox"
    class="h-4 w-4 text-teal-600 focus:ring-teal-500 border-gray-300 rounded">
  <label for="checkbox" class="ml-2 text-sm text-gray-700">
    I agree to the terms and conditions
  </label>
</div>
```

#### Radio Buttons

```html
<div class="mb-4">
  <label class="block text-sm font-semibold text-gray-700 mb-2">
    Choose an option
  </label>
  <div class="space-y-2">
    <div class="flex items-center">
      <input
        type="radio"
        id="radio1"
        name="radio-group"
        value="1"
        class="h-4 w-4 text-teal-600 focus:ring-teal-500 border-gray-300">
      <label for="radio1" class="ml-2 text-sm text-gray-700">
        Option 1
      </label>
    </div>
    <div class="flex items-center">
      <input
        type="radio"
        id="radio2"
        name="radio-group"
        value="2"
        class="h-4 w-4 text-teal-600 focus:ring-teal-500 border-gray-300">
      <label for="radio2" class="ml-2 text-sm text-gray-700">
        Option 2
      </label>
    </div>
  </div>
</div>
```

#### Input with Error State

```html
<div class="mb-4">
  <label for="error-input" class="block text-sm font-semibold text-gray-700 mb-2">
    Field with Error
  </label>
  <input
    type="text"
    id="error-input"
    class="w-full px-4 py-2 border-2 border-red-500 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent transition-all duration-200"
    placeholder="Enter text"
    aria-invalid="true"
    aria-describedby="error-message">
  <p id="error-message" class="mt-1 text-sm text-red-600">
    This field is required
  </p>
</div>
```

#### Input with Success State

```html
<div class="mb-4">
  <label for="success-input" class="block text-sm font-semibold text-gray-700 mb-2">
    Field with Success
  </label>
  <input
    type="text"
    id="success-input"
    class="w-full px-4 py-2 border-2 border-green-500 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent transition-all duration-200"
    placeholder="Enter text"
    value="Valid input">
  <p class="mt-1 text-sm text-green-600">
    ✓ Looks good!
  </p>
</div>
```

### Links

#### Standard Link

```html
<a href="#" class="text-teal-600 hover:text-teal-700 transition-colors duration-200 underline">
  Standard Link
</a>
```

#### Link without Underline

```html
<a href="#" class="text-teal-600 hover:text-teal-700 hover:underline transition-all duration-200">
  Hover to Underline
</a>
```

#### Footer Link

```html
<a href="#" class="text-gray-300 hover:text-teal-400 transition-colors duration-200">
  Footer Link
</a>
```

#### Link with Icon

```html
<a href="#" class="inline-flex items-center text-teal-600 hover:text-teal-700 transition-colors duration-200 group">
  <span>Link Text</span>
  <svg class="ml-2 h-4 w-4 transition-transform group-hover:translate-x-1" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
    <path fill-rule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clip-rule="evenodd"/>
  </svg>
</a>
```

### Badges and Tags

#### Primary Badge

```html
<span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-teal-100 text-teal-800">
  Primary Badge
</span>
```

#### Success Badge

```html
<span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800">
  ✓ Verified
</span>
```

#### Warning Badge

```html
<span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-yellow-100 text-yellow-800">
  ⚠ Warning
</span>
```

#### Error Badge

```html
<span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800">
  ✕ Error
</span>
```

#### Neutral Badge

```html
<span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-gray-100 text-gray-800">
  Neutral
</span>
```

#### Badge with Dot

```html
<span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-teal-100 text-teal-800">
  <span class="h-2 w-2 rounded-full bg-teal-600 mr-2"></span>
  Active
</span>
```

### Alerts and Notifications

#### Success Alert

```html
<div class="bg-green-50 border-l-4 border-green-500 p-4 rounded-lg" role="alert">
  <div class="flex items-start">
    <svg class="h-5 w-5 text-green-500 mt-0.5" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
    </svg>
    <div class="ml-3">
      <h3 class="text-sm font-semibold text-green-800">Success!</h3>
      <p class="text-sm text-green-700 mt-1">Your action was completed successfully.</p>
    </div>
  </div>
</div>
```

#### Error Alert

```html
<div class="bg-red-50 border-l-4 border-red-500 p-4 rounded-lg" role="alert">
  <div class="flex items-start">
    <svg class="h-5 w-5 text-red-500 mt-0.5" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
    </svg>
    <div class="ml-3">
      <h3 class="text-sm font-semibold text-red-800">Error!</h3>
      <p class="text-sm text-red-700 mt-1">There was a problem with your request.</p>
    </div>
  </div>
</div>
```

#### Warning Alert

```html
<div class="bg-yellow-50 border-l-4 border-yellow-500 p-4 rounded-lg" role="alert">
  <div class="flex items-start">
    <svg class="h-5 w-5 text-yellow-500 mt-0.5" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
      <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
    </svg>
    <div class="ml-3">
      <h3 class="text-sm font-semibold text-yellow-800">Warning!</h3>
      <p class="text-sm text-yellow-700 mt-1">Please review this information carefully.</p>
    </div>
  </div>
</div>
```

#### Info Alert

```html
<div class="bg-teal-50 border-l-4 border-teal-500 p-4 rounded-lg" role="alert">
  <div class="flex items-start">
    <svg class="h-5 w-5 text-teal-500 mt-0.5" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
    </svg>
    <div class="ml-3">
      <h3 class="text-sm font-semibold text-teal-800">Information</h3>
      <p class="text-sm text-teal-700 mt-1">Here's some helpful information for you.</p>
    </div>
  </div>
</div>
```

#### Dismissible Alert

```html
<div class="bg-teal-50 border-l-4 border-teal-500 p-4 rounded-lg relative" role="alert">
  <button class="absolute top-4 right-4 text-teal-500 hover:text-teal-700" aria-label="Close">
    <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
      <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>
    </svg>
  </button>
  <div class="flex items-start pr-8">
    <svg class="h-5 w-5 text-teal-500 mt-0.5" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/>
    </svg>
    <div class="ml-3">
      <p class="text-sm text-teal-700">This alert can be dismissed.</p>
    </div>
  </div>
</div>
```

### Modals and Dropdowns

#### Modal Overlay

```html
<!-- Modal Backdrop -->
<div class="fixed inset-0 bg-gray-900 bg-opacity-50 backdrop-blur-sm z-40" aria-hidden="true"></div>

<!-- Modal Container -->
<div class="fixed inset-0 z-50 overflow-y-auto" role="dialog" aria-modal="true">
  <div class="flex min-h-full items-center justify-center p-4">
    <div class="bg-white rounded-xl shadow-2xl max-w-md w-full p-6 transform transition-all">
      <!-- Modal Header -->
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-xl font-bold text-gray-900">Modal Title</h3>
        <button class="text-gray-400 hover:text-gray-600" aria-label="Close">
          <svg class="h-6 w-6" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
            <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>
          </svg>
        </button>
      </div>

      <!-- Modal Body -->
      <div class="mb-6">
        <p class="text-gray-700">Modal content goes here.</p>
      </div>

      <!-- Modal Footer -->
      <div class="flex justify-end gap-3">
        <button class="text-gray-700 hover:text-teal-600 hover:bg-teal-50 px-4 py-2 rounded-lg text-sm font-medium transition-all duration-200">
          Cancel
        </button>
        <button class="bg-gradient-to-r from-teal-600 to-gray-700 hover:from-teal-700 hover:to-gray-800 text-white px-4 py-2 rounded-lg text-sm font-semibold transition-all duration-200">
          Confirm
        </button>
      </div>
    </div>
  </div>
</div>
```

#### Dropdown Menu

```html
<div class="relative" data-controller="dropdown">
  <!-- Dropdown Button -->
  <button
    data-dropdown-target="button"
    data-action="click->dropdown#toggle"
    class="inline-flex items-center px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2">
    Options
    <svg class="ml-2 h-4 w-4" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
      <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd"/>
    </svg>
  </button>

  <!-- Dropdown Menu -->
  <div
    data-dropdown-target="menu"
    class="hidden absolute right-0 mt-2 w-56 rounded-lg shadow-lg bg-white ring-1 ring-gray-200 z-50">
    <div class="py-1">
      <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-teal-50 hover:text-teal-600 transition-colors">
        Option 1
      </a>
      <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-teal-50 hover:text-teal-600 transition-colors">
        Option 2
      </a>
      <a href="#" class="block px-4 py-2 text-sm text-gray-700 hover:bg-teal-50 hover:text-teal-600 transition-colors">
        Option 3
      </a>
    </div>
  </div>
</div>
```

### Navigation Components

#### Breadcrumbs

```html
<nav class="flex" aria-label="Breadcrumb">
  <ol class="inline-flex items-center space-x-1 md:space-x-3">
    <li class="inline-flex items-center">
      <a href="#" class="text-gray-700 hover:text-teal-600 inline-flex items-center text-sm font-medium">
        <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
          <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z"/>
        </svg>
        Home
      </a>
    </li>
    <li>
      <div class="flex items-center">
        <svg class="w-6 h-6 text-gray-400" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
          <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd"/>
        </svg>
        <a href="#" class="ml-1 text-gray-700 hover:text-teal-600 text-sm font-medium md:ml-2">
          Category
        </a>
      </div>
    </li>
    <li aria-current="page">
      <div class="flex items-center">
        <svg class="w-6 h-6 text-gray-400" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
          <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd"/>
        </svg>
        <span class="ml-1 text-sm font-medium text-gray-500 md:ml-2">Current Page</span>
      </div>
    </li>
  </ol>
</nav>
```

#### Pagination

```html
<nav class="flex items-center justify-between border-t border-gray-200 px-4 sm:px-0" aria-label="Pagination">
  <div class="-mt-px flex w-0 flex-1">
    <a href="#" class="inline-flex items-center border-t-2 border-transparent pt-4 pr-1 text-sm font-medium text-gray-500 hover:border-teal-500 hover:text-teal-600">
      <svg class="mr-3 h-5 w-5" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
        <path fill-rule="evenodd" d="M7.707 14.707a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l2.293 2.293a1 1 0 010 1.414z" clip-rule="evenodd"/>
      </svg>
      Previous
    </a>
  </div>
  <div class="hidden md:-mt-px md:flex">
    <a href="#" class="inline-flex items-center border-t-2 border-transparent px-4 pt-4 text-sm font-medium text-gray-500 hover:border-teal-500 hover:text-teal-600">1</a>
    <a href="#" class="inline-flex items-center border-t-2 border-teal-500 px-4 pt-4 text-sm font-medium text-teal-600" aria-current="page">2</a>
    <a href="#" class="inline-flex items-center border-t-2 border-transparent px-4 pt-4 text-sm font-medium text-gray-500 hover:border-teal-500 hover:text-teal-600">3</a>
  </div>
  <div class="-mt-px flex w-0 flex-1 justify-end">
    <a href="#" class="inline-flex items-center border-t-2 border-transparent pt-4 pl-1 text-sm font-medium text-gray-500 hover:border-teal-500 hover:text-teal-600">
      Next
      <svg class="ml-3 h-5 w-5" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
        <path fill-rule="evenodd" d="M12.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-2.293-2.293a1 1 0 010-1.414z" clip-rule="evenodd"/>
      </svg>
    </a>
  </div>
</nav>
```

---

## Visual Effects

### Gradients

#### Background Gradients

```css
/* Primary Gradient (Teal to Gray) - For CTAs and Buttons */
bg-gradient-to-r from-teal-600 to-gray-700

/* Hero/Dark Section Gradient - For hero sections, footer, dark backgrounds */
bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900

/* Light Gradient - For subtle backgrounds */
bg-gradient-to-br from-teal-50 to-white

/* Hover Gradient - For button hover states */
hover:from-teal-700 hover:to-gray-800

/* Vertical Gradient - For sections with fade effect */
bg-gradient-to-b from-white to-gray-50
```

**Usage Examples**:

```html
<!-- Primary CTA Button -->
<button class="bg-gradient-to-r from-teal-600 to-gray-700 hover:from-teal-700 hover:to-gray-800 text-white px-6 py-2 rounded-lg">
  Get Started
</button>

<!-- Hero Section Background -->
<section class="relative bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 py-24">
  <!-- Content -->
</section>

<!-- Light Section Background -->
<section class="bg-gradient-to-br from-teal-50 to-white py-16">
  <!-- Content -->
</section>
```

#### Text Gradients

```css
/* Primary Text Gradient (Teal to Gray) */
bg-gradient-to-r from-teal-600 to-gray-700 bg-clip-text text-transparent

/* Light Text Gradient (Teal to White) - For dark backgrounds */
bg-gradient-to-r from-teal-400 to-white bg-clip-text text-transparent

/* Vibrant Text Gradient */
bg-gradient-to-r from-teal-500 to-teal-600 bg-clip-text text-transparent
```

**Usage Examples**:

```html
<!-- Gradient Heading on Light Background -->
<h1 class="text-5xl font-bold bg-gradient-to-r from-teal-600 to-gray-700 bg-clip-text text-transparent">
  WellnessConnect
</h1>

<!-- Gradient Heading on Dark Background -->
<h1 class="text-5xl font-bold bg-gradient-to-r from-teal-400 to-white bg-clip-text text-transparent">
  WellnessConnect
</h1>
```

#### Image Overlays

```css
/* Standard Overlay - For images with text overlay */
bg-gradient-to-t from-gray-900/40 via-gray-900/10 to-transparent

/* Dark Overlay - For images needing more contrast */
bg-gradient-to-t from-gray-900/60 via-gray-900/20 to-transparent

/* Teal Overlay - For brand-colored overlays */
bg-gradient-to-t from-teal-900/50 via-teal-900/20 to-transparent

/* Bottom-to-Top Overlay - For hero images */
bg-gradient-to-t from-gray-900/80 via-gray-900/40 to-transparent
```

**Usage Examples**:

```html
<!-- Image Card with Overlay -->
<div class="relative h-64 rounded-xl overflow-hidden">
  <img src="image.jpg" alt="Description" class="w-full h-full object-cover">
  <div class="absolute inset-0 bg-gradient-to-t from-gray-900/40 via-gray-900/10 to-transparent"></div>
  <div class="absolute bottom-0 left-0 right-0 p-6 text-white">
    <h3 class="text-xl font-bold">Card Title</h3>
    <p class="text-sm">Card description</p>
  </div>
</div>

<!-- Hero Section with Image Overlay -->
<section class="relative h-screen">
  <img src="hero.jpg" alt="Hero" class="absolute inset-0 w-full h-full object-cover">
  <div class="absolute inset-0 bg-gradient-to-t from-gray-900/80 via-gray-900/40 to-transparent"></div>
  <div class="relative z-10 flex items-center justify-center h-full text-white">
    <h1 class="text-6xl font-bold">Welcome to WellnessConnect</h1>
  </div>
</section>
```

### Shadows

#### Shadow Scale

| Tailwind Class | Usage | Example |
|----------------|-------|---------|
| `shadow-sm` | Subtle elevation | Input fields, small cards |
| `shadow` | Default shadow | Standard cards |
| `shadow-md` | **Standard elevation** | Cards, buttons |
| `shadow-lg` | **Prominent elevation** | Modals, dropdowns, featured cards |
| `shadow-xl` | High elevation | Popovers, tooltips |
| `shadow-2xl` | Maximum elevation | Full-screen modals, overlays |

#### Shadow Patterns

```html
<!-- Card with Hover Shadow -->
<div class="bg-white rounded-xl shadow-md hover:shadow-xl transition-shadow duration-200 p-6">
  <!-- Content -->
</div>

<!-- Button with Shadow -->
<button class="bg-gradient-to-r from-teal-600 to-gray-700 text-white px-6 py-2 rounded-lg shadow-md hover:shadow-lg transition-all duration-200">
  Click Me
</button>

<!-- Dropdown with Large Shadow -->
<div class="absolute mt-2 w-56 rounded-lg shadow-lg bg-white ring-1 ring-gray-200">
  <!-- Dropdown content -->
</div>
```

### Border Radius

| Tailwind Class | Size (rem) | Size (px) | Usage |
|----------------|------------|-----------|-------|
| `rounded-sm` | 0.125rem | 2px | Small elements, tight corners |
| `rounded` | 0.25rem | 4px | Default rounding |
| `rounded-md` | 0.375rem | 6px | Input fields |
| `rounded-lg` | 0.5rem | 8px | **Standard** - Buttons, cards |
| `rounded-xl` | 0.75rem | 12px | **Large cards**, sections |
| `rounded-2xl` | 1rem | 16px | Hero sections, large containers |
| `rounded-3xl` | 1.5rem | 24px | Extra large containers |
| `rounded-full` | 9999px | Full | Avatars, badges, pills |

### Transitions and Animations

#### Standard Transitions

```css
/* All Properties - Use for complex state changes */
transition-all duration-200

/* Colors Only - Use for hover color changes */
transition-colors duration-200

/* Transform Only - Use for scale, translate, rotate */
transition-transform duration-200

/* Shadow Only - Use for elevation changes */
transition-shadow duration-200

/* Opacity Only - Use for fade effects */
transition-opacity duration-200
```

#### Hover Effects

```html
<!-- Scale Up on Hover -->
<div class="transform hover:scale-105 transition-transform duration-200">
  <!-- Content -->
</div>

<!-- Translate on Hover -->
<a href="#" class="group inline-flex items-center">
  <span>Link Text</span>
  <svg class="ml-2 transition-transform group-hover:translate-x-1">
    <!-- Arrow icon -->
  </svg>
</a>

<!-- Opacity Change on Hover -->
<div class="opacity-0 group-hover:opacity-100 transition-opacity duration-200">
  <!-- Hidden content that appears on hover -->
</div>

<!-- Shadow Elevation on Hover -->
<div class="shadow-md hover:shadow-xl transition-shadow duration-200">
  <!-- Content -->
</div>
```

#### Custom Animations (Defined in application.css)

```css
/* Blob Animation - For decorative background elements */
@keyframes blob {
  0%, 100% { transform: translate(0, 0) scale(1); }
  25% { transform: translate(20px, -50px) scale(1.1); }
  50% { transform: translate(-20px, 20px) scale(0.9); }
  75% { transform: translate(50px, 50px) scale(1.05); }
}

.animate-blob {
  animation: blob 7s infinite;
}

/* Float Animation - For subtle floating effect */
@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}

.animate-float {
  animation: float 3s ease-in-out infinite;
}

/* Pulse Subtle - For gentle pulsing effect */
@keyframes pulse-subtle {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.8; }
}

.animate-pulse-subtle {
  animation: pulse-subtle 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}

/* Gradient Animation - For animated gradient backgrounds */
@keyframes gradient {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

.animate-gradient {
  background-size: 200% 200%;
  animation: gradient 15s ease infinite;
}
```

**Usage Examples**:

```html
<!-- Floating Card -->
<div class="bg-white rounded-xl shadow-lg p-6 animate-float">
  <!-- Content -->
</div>

<!-- Blob Background Element -->
<div class="absolute top-0 right-0 w-96 h-96 bg-teal-500/10 rounded-full blur-3xl animate-blob">
</div>

<!-- Animated Gradient Background -->
<section class="bg-gradient-to-r from-teal-600 via-gray-700 to-teal-600 animate-gradient">
  <!-- Content -->
</section>
```

---

## Background Usage Guidelines

### When to Use Dark Gradient Backgrounds

**Dark gradient backgrounds** (`bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900`) should be used for:

1. **Hero Sections**
   - Homepage hero
   - Landing page headers
   - Feature introduction sections

   ```html
   <section class="relative bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 py-24">
     <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-white">
       <h1 class="text-5xl font-bold mb-4">Welcome to WellnessConnect</h1>
       <p class="text-xl text-gray-300">Your healthcare journey starts here</p>
     </div>
   </section>
   ```

2. **Footer**
   - Main footer section
   - Newsletter signup areas within footer

   ```html
   <footer class="relative bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 text-white py-12">
     <!-- Footer content -->
   </footer>
   ```

3. **Call-to-Action (CTA) Sections**
   - Provider signup CTAs
   - Major conversion sections
   - Feature highlights

   ```html
   <section class="relative bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 py-16">
     <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center text-white">
       <h2 class="text-4xl font-bold mb-4">Are You a Healthcare Provider?</h2>
       <p class="text-xl text-gray-300 mb-8">Join our platform today</p>
       <button class="bg-white text-teal-600 px-8 py-3 rounded-lg font-bold hover:bg-gray-100">
         Get Started
       </button>
     </div>
   </section>
   ```

4. **Testimonial Sections** (Optional)
   - Can use dark backgrounds for dramatic effect
   - Ensure text contrast is maintained

   ```html
   <section class="bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 py-16">
     <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
       <!-- Testimonial cards with white backgrounds -->
     </div>
   </section>
   ```

### When to Use White/Light Backgrounds

**White or light backgrounds** should be used for:

1. **Forms and Input Pages**
   - Registration forms
   - Login pages
   - Profile editing
   - Appointment booking

   ```html
   <section class="bg-white py-16">
     <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
       <form class="bg-white rounded-xl shadow-lg p-8">
         <!-- Form fields -->
       </form>
     </div>
   </section>
   ```

2. **Dashboards and Data-Heavy Pages**
   - Patient dashboards
   - Provider dashboards
   - Analytics pages
   - Payment history

   ```html
   <div class="bg-gray-50 min-h-screen py-8">
     <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
       <!-- Dashboard content -->
     </div>
   </div>
   ```

3. **Content Pages**
   - About pages
   - Blog posts
   - Help/FAQ pages
   - Terms and privacy

   ```html
   <article class="bg-white py-16">
     <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
       <div class="prose prose-lg">
         <!-- Article content -->
       </div>
     </div>
   </article>
   ```

4. **List and Grid Views**
   - Provider listings
   - Service categories
   - Search results

   ```html
   <section class="bg-gray-50 py-16">
     <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
       <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
         <!-- Cards with white backgrounds -->
       </div>
     </div>
   </section>
   ```

### Alternating Backgrounds Pattern

For long pages with multiple sections, alternate between white and light gray backgrounds:

```html
<!-- Section 1 - White -->
<section class="bg-white py-16">
  <!-- Content -->
</section>

<!-- Section 2 - Light Gray -->
<section class="bg-gray-50 py-16">
  <!-- Content -->
</section>

<!-- Section 3 - White -->
<section class="bg-white py-16">
  <!-- Content -->
</section>

<!-- Section 4 - Dark Gradient (CTA) -->
<section class="bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 py-16">
  <!-- Content -->
</section>
```

### Image Overlay Guidelines

When placing text over images, always use gradient overlays:

```html
<!-- Light text on image - Use dark overlay -->
<div class="relative h-96">
  <img src="image.jpg" alt="Description" class="absolute inset-0 w-full h-full object-cover">
  <div class="absolute inset-0 bg-gradient-to-t from-gray-900/60 via-gray-900/20 to-transparent"></div>
  <div class="relative z-10 flex items-end h-full p-8 text-white">
    <h2 class="text-3xl font-bold">Text Over Image</h2>
  </div>
</div>
```

### Background Color Decision Tree

```text
Is this a conversion-focused section (CTA, hero, signup)?
├─ YES → Use dark gradient background
└─ NO → Is this a form or data input page?
    ├─ YES → Use white background
    └─ NO → Is this a content-heavy page (dashboard, listings)?
        ├─ YES → Use white or light gray background
        └─ NO → Is this the footer?
            ├─ YES → Use dark gradient background
            └─ NO → Use white or alternate white/gray-50
```

---

## Accessibility Standards

WellnessConnect is committed to WCAG 2.1 AA compliance to ensure all users can access and use the platform effectively.

### Color Contrast Requirements

#### Text Contrast

| Text Size | Minimum Ratio | Recommended Ratio |
|-----------|---------------|-------------------|
| Normal text (< 18px) | 4.5:1 | 7:1 (AAA) |
| Large text (≥ 18px or ≥ 14px bold) | 3:1 | 4.5:1 (AAA) |
| UI components | 3:1 | 4.5:1 |

#### Approved Color Combinations

✅ **Passing Combinations**:
- `gray-900` on `white` (16.1:1) - AAA
- `gray-700` on `white` (9.7:1) - AAA
- `gray-600` on `white` (7.2:1) - AAA
- `teal-600` on `white` (4.8:1) - AA
- `white` on `teal-600` (4.8:1) - AA
- `white` on `gray-900` (16.1:1) - AAA
- `teal-400` on `gray-900` (7.5:1) - AAA
- `gray-300` on `gray-900` (5.9:1) - AA

❌ **Failing Combinations to Avoid**:
- `gray-400` on `white` (2.8:1) - Fails AA
- `teal-200` on `white` (1.9:1) - Fails AA
- `gray-500` on `teal-600` (2.1:1) - Fails AA

### Focus States

All interactive elements MUST have visible focus indicators:

```html
<!-- Standard Focus Ring -->
<button class="focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2">
  Button
</button>

<!-- Focus Ring on Dark Background -->
<button class="focus:outline-none focus:ring-2 focus:ring-teal-400 focus:ring-offset-2 focus:ring-offset-gray-900">
  Button on Dark
</button>

<!-- Focus Ring for Inputs -->
<input class="focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent">
```

**Requirements**:
- Focus ring must be at least 2px wide
- Focus ring must have sufficient contrast (3:1 minimum)
- Focus ring must be visible on all backgrounds
- Never use `outline-none` without providing an alternative focus indicator

### ARIA Labels and Semantic HTML

#### Required ARIA Labels

```html
<!-- Icon-only buttons MUST have aria-label -->
<button aria-label="Close menu">
  <svg aria-hidden="true"><!-- Icon --></svg>
</button>

<!-- Decorative images MUST have empty alt -->
<img src="decorative.jpg" alt="" role="presentation">

<!-- Informative images MUST have descriptive alt -->
<img src="doctor.jpg" alt="Dr. Smith, cardiologist">

<!-- Form inputs MUST have associated labels -->
<label for="email">Email Address</label>
<input type="email" id="email" name="email" aria-required="true">

<!-- Error messages MUST be associated with inputs -->
<input type="text" id="name" aria-invalid="true" aria-describedby="name-error">
<p id="name-error" role="alert">This field is required</p>

<!-- Modals MUST have role and aria-modal -->
<div role="dialog" aria-modal="true" aria-labelledby="modal-title">
  <h2 id="modal-title">Modal Title</h2>
</div>

<!-- Alerts MUST have role="alert" for screen readers -->
<div role="alert" class="bg-red-50 border-l-4 border-red-500 p-4">
  Error message
</div>
```

### Keyboard Navigation

All interactive elements must be keyboard accessible:

#### Tab Order

```html
<!-- Ensure logical tab order with tabindex -->
<button tabindex="0">First</button>
<button tabindex="0">Second</button>
<button tabindex="0">Third</button>

<!-- Skip to main content link -->
<a href="#main-content" class="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 bg-teal-600 text-white px-4 py-2 rounded-lg">
  Skip to main content
</a>

<main id="main-content">
  <!-- Page content -->
</main>
```

#### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Tab` | Move to next interactive element |
| `Shift + Tab` | Move to previous interactive element |
| `Enter` | Activate button or link |
| `Space` | Activate button or toggle checkbox |
| `Escape` | Close modal or dropdown |
| `Arrow Keys` | Navigate within dropdowns, carousels, tabs |

#### Dropdown Keyboard Support

```html
<!-- Dropdown must support keyboard navigation -->
<div data-controller="dropdown">
  <button
    data-dropdown-target="button"
    data-action="click->dropdown#toggle keydown.escape->dropdown#close"
    aria-haspopup="true"
    aria-expanded="false">
    Options
  </button>
  <div
    data-dropdown-target="menu"
    role="menu"
    data-action="keydown.escape->dropdown#close keydown.arrow-down->dropdown#nextItem keydown.arrow-up->dropdown#previousItem">
    <a href="#" role="menuitem">Option 1</a>
    <a href="#" role="menuitem">Option 2</a>
  </div>
</div>
```

### Touch Targets

All interactive elements must meet minimum touch target sizes:

| Device | Minimum Size | Recommended Size |
|--------|--------------|------------------|
| Mobile | 44px × 44px | 48px × 48px |
| Tablet | 44px × 44px | 48px × 48px |
| Desktop | 24px × 24px | 32px × 32px |

```html
<!-- Mobile-friendly button -->
<button class="min-h-[44px] min-w-[44px] px-6 py-2 bg-teal-600 text-white rounded-lg">
  Tap Me
</button>

<!-- Icon button with adequate touch target -->
<button class="p-3 hover:bg-teal-50 rounded-full" aria-label="Menu">
  <svg class="h-6 w-6"><!-- Icon --></svg>
</button>
```

### Screen Reader Support

#### Screen Reader Only Text

```html
<!-- Visually hidden but available to screen readers -->
<span class="sr-only">
  Additional context for screen readers
</span>

<!-- Example: Icon with screen reader text -->
<button>
  <svg aria-hidden="true"><!-- Icon --></svg>
  <span class="sr-only">Close menu</span>
</button>
```

#### Live Regions

```html
<!-- Announce dynamic content changes -->
<div aria-live="polite" aria-atomic="true">
  <p>Content that updates dynamically</p>
</div>

<!-- For urgent announcements -->
<div aria-live="assertive" role="alert">
  <p>Critical error message</p>
</div>
```

### Form Accessibility

```html
<!-- Accessible form example -->
<form>
  <!-- Required field -->
  <div class="mb-4">
    <label for="name" class="block text-sm font-semibold text-gray-700 mb-2">
      Name <span class="text-red-600" aria-label="required">*</span>
    </label>
    <input
      type="text"
      id="name"
      name="name"
      required
      aria-required="true"
      aria-describedby="name-help"
      class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500">
    <p id="name-help" class="mt-1 text-sm text-gray-600">
      Enter your full name
    </p>
  </div>

  <!-- Field with error -->
  <div class="mb-4">
    <label for="email" class="block text-sm font-semibold text-gray-700 mb-2">
      Email <span class="text-red-600" aria-label="required">*</span>
    </label>
    <input
      type="email"
      id="email"
      name="email"
      required
      aria-required="true"
      aria-invalid="true"
      aria-describedby="email-error"
      class="w-full px-4 py-2 border-2 border-red-500 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500">
    <p id="email-error" class="mt-1 text-sm text-red-600" role="alert">
      Please enter a valid email address
    </p>
  </div>

  <!-- Fieldset for grouped inputs -->
  <fieldset class="mb-4">
    <legend class="block text-sm font-semibold text-gray-700 mb-2">
      Preferred Contact Method
    </legend>
    <div class="space-y-2">
      <div class="flex items-center">
        <input type="radio" id="contact-email" name="contact" value="email" class="h-4 w-4 text-teal-600">
        <label for="contact-email" class="ml-2 text-sm text-gray-700">Email</label>
      </div>
      <div class="flex items-center">
        <input type="radio" id="contact-phone" name="contact" value="phone" class="h-4 w-4 text-teal-600">
        <label for="contact-phone" class="ml-2 text-sm text-gray-700">Phone</label>
      </div>
    </div>
  </fieldset>

  <!-- Submit button -->
  <button
    type="submit"
    class="bg-gradient-to-r from-teal-600 to-gray-700 hover:from-teal-700 hover:to-gray-800 text-white px-6 py-2 rounded-lg font-semibold transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2">
    Submit Form
  </button>
</form>
```

### Accessibility Testing Checklist

- [ ] All images have appropriate alt text
- [ ] All interactive elements are keyboard accessible
- [ ] All interactive elements have visible focus states
- [ ] Color contrast meets WCAG 2.1 AA standards
- [ ] Forms have proper labels and error messages
- [ ] ARIA labels are used for icon-only buttons
- [ ] Touch targets are at least 44px × 44px on mobile
- [ ] Page has proper heading hierarchy (h1-h6)
- [ ] Skip to main content link is present
- [ ] Modals can be closed with Escape key
- [ ] Dropdowns support keyboard navigation
- [ ] Dynamic content changes are announced to screen readers
- [ ] No content relies solely on color to convey meaning

---

## Page-Specific Guidelines

### Homepage

**Background Pattern**:
```html
<!-- Hero Section - Dark Gradient -->
<section class="bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 py-24">
  <!-- Hero content -->
</section>

<!-- Services Carousel - White -->
<section class="bg-white py-16">
  <!-- Carousel -->
</section>

<!-- How It Works - Light Gray -->
<section class="bg-gray-50 py-16">
  <!-- Content -->
</section>

<!-- Why Choose - White -->
<section class="bg-white py-16">
  <!-- Content -->
</section>

<!-- Testimonials - Light Gray -->
<section class="bg-gray-50 py-16">
  <!-- Testimonials -->
</section>

<!-- Provider CTA - Dark Gradient -->
<section class="bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 py-16">
  <!-- CTA content -->
</section>

<!-- Footer - Dark Gradient -->
<footer class="bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 py-12">
  <!-- Footer content -->
</footer>
```

### Dashboard Pages

**Background**: White or light gray (`bg-white` or `bg-gray-50`)

```html
<div class="bg-gray-50 min-h-screen">
  <!-- Navbar -->
  <nav class="bg-white shadow-sm">
    <!-- Navigation -->
  </nav>

  <!-- Main Content -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Dashboard widgets in white cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div class="bg-white rounded-xl shadow-md p-6">
        <!-- Widget content -->
      </div>
    </div>
  </main>
</div>
```

### Form Pages (Login, Registration, Booking)

**Background**: White with centered form container

```html
<div class="bg-gray-50 min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
  <div class="max-w-md w-full">
    <div class="bg-white rounded-xl shadow-lg p-8">
      <h2 class="text-3xl font-bold text-gray-900 mb-6">Sign In</h2>
      <form>
        <!-- Form fields -->
      </form>
    </div>
  </div>
</div>
```

### Provider/Service Listing Pages

**Background**: Light gray with white cards

```html
<div class="bg-gray-50 min-h-screen py-8">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Filters -->
    <div class="bg-white rounded-xl shadow-md p-6 mb-6">
      <!-- Filter controls -->
    </div>

    <!-- Results Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div class="bg-white rounded-xl shadow-md hover:shadow-xl transition-shadow duration-200">
        <!-- Provider card -->
      </div>
    </div>
  </div>
</div>
```

### Content Pages (About, Help, Blog)

**Background**: White with max-width container

```html
<article class="bg-white py-16">
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
    <h1 class="text-4xl font-bold text-gray-900 mb-6">Page Title</h1>
    <div class="prose prose-lg max-w-none">
      <!-- Article content -->
    </div>
  </div>
</article>
```

---

## Usage Guidelines

### When to Use Teal

Use **teal** (`teal-600`, `teal-500`, `teal-400`) for:

1. **Primary Actions**
   - Main CTA buttons
   - Form submit buttons
   - "Get Started" buttons
   - "Book Appointment" buttons

2. **Interactive Elements**
   - Links (text and hover states)
   - Active navigation items
   - Selected states
   - Toggle switches (active state)

3. **Brand Elements**
   - Logo icon
   - Brand headings (with gradient)
   - Section eyebrow text
   - Accent decorations

4. **Positive Indicators**
   - Success messages (use `green-500` for success, `teal-600` for info)
   - Verified badges
   - Active status indicators
   - Progress indicators

5. **Hover States**
   - Link hover color
   - Button hover backgrounds
   - Card hover borders
   - Icon hover colors

**Examples**:

```html
<!-- Primary CTA -->
<button class="bg-gradient-to-r from-teal-600 to-gray-700 text-white px-6 py-2 rounded-lg">
  Get Started
</button>

<!-- Link -->
<a href="#" class="text-teal-600 hover:text-teal-700">
  Learn More
</a>

<!-- Active Nav Item -->
<a href="#" class="text-teal-600 border-b-2 border-teal-600">
  Dashboard
</a>

<!-- Verified Badge -->
<span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-teal-100 text-teal-800">
  ✓ Verified
</span>
```

### When to Use Gray

Use **gray** (`gray-900`, `gray-700`, `gray-600`, `gray-300`) for:

1. **Text Content**
   - Primary text: `gray-900`
   - Secondary text: `gray-700`
   - Tertiary text: `gray-600`
   - Placeholder text: `gray-400`
   - Disabled text: `gray-400`

2. **Backgrounds**
   - Dark sections: `gray-900`
   - Alternating sections: `gray-50`
   - Card backgrounds: `white` or `gray-100`
   - Input backgrounds: `white`

3. **Borders and Dividers**
   - Standard borders: `gray-200`
   - Subtle dividers: `gray-100`
   - Input borders: `gray-300`

4. **Gradient Combinations**
   - Paired with teal in gradients
   - Dark gradient backgrounds
   - Button gradients

**Examples**:

```html
<!-- Text Hierarchy -->
<h1 class="text-4xl font-bold text-gray-900">Primary Heading</h1>
<p class="text-base text-gray-700">Body text content</p>
<p class="text-sm text-gray-600">Secondary information</p>

<!-- Card with Border -->
<div class="bg-white border border-gray-200 rounded-xl p-6">
  <!-- Content -->
</div>

<!-- Disabled Button -->
<button disabled class="bg-gray-300 text-gray-500 px-6 py-2 rounded-lg cursor-not-allowed">
  Disabled
</button>
```

### When to Use White

Use **white** for:

1. **Page Backgrounds**
   - Main content areas
   - Form pages
   - Dashboard pages
   - Content pages

2. **Card Backgrounds**
   - Content cards
   - Feature cards
   - Provider cards
   - Testimonial cards

3. **Text on Dark Backgrounds**
   - Hero section text
   - Footer text
   - Dark CTA section text
   - Text over images (with overlay)

4. **Button Text**
   - Primary button text
   - CTA button text
   - Buttons on dark backgrounds

**Examples**:

```html
<!-- Page Background -->
<div class="bg-white min-h-screen">
  <!-- Content -->
</div>

<!-- Card -->
<div class="bg-white rounded-xl shadow-lg p-6">
  <!-- Card content -->
</div>

<!-- Text on Dark Background -->
<section class="bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 text-white py-16">
  <h2 class="text-4xl font-bold">White Text on Dark</h2>
</section>
```

### Do's and Don'ts

#### ✅ Do's

- **Do** use teal for all primary CTAs and interactive elements
- **Do** maintain consistent spacing using the spacing scale
- **Do** use dark gradient backgrounds for hero sections and CTAs
- **Do** use white/light backgrounds for forms and data-heavy pages
- **Do** ensure all text meets WCAG 2.1 AA contrast requirements
- **Do** provide focus states for all interactive elements
- **Do** use responsive breakpoints for mobile-first design
- **Do** add ARIA labels to icon-only buttons
- **Do** use semantic HTML (header, nav, main, article, footer)
- **Do** test with keyboard navigation
- **Do** use the established component patterns
- **Do** add image overlays when placing text over images

#### ❌ Don'ts

- **Don't** use colors outside the defined palette
- **Don't** use indigo or purple (old color scheme)
- **Don't** use dark backgrounds for forms or dashboards
- **Don't** use white backgrounds for hero sections or footer
- **Don't** place text directly on images without overlays
- **Don't** use `outline-none` without providing focus indicators
- **Don't** use color alone to convey information
- **Don't** create touch targets smaller than 44px on mobile
- **Don't** skip heading levels (h1 → h3)
- **Don't** use generic link text like "click here"
- **Don't** forget alt text on images
- **Don't** use low-contrast color combinations

### Component Composition Examples

#### Feature Card with Icon

```html
<div class="bg-white rounded-xl shadow-lg hover:shadow-xl transition-shadow duration-200 p-6">
  <!-- Icon -->
  <div class="h-12 w-12 rounded-lg bg-teal-100 flex items-center justify-center mb-4">
    <svg class="h-6 w-6 text-teal-600" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
      <!-- Icon path -->
    </svg>
  </div>

  <!-- Content -->
  <h3 class="text-xl font-semibold text-gray-900 mb-2">Feature Title</h3>
  <p class="text-gray-600 mb-4">Feature description goes here.</p>

  <!-- Link -->
  <a href="#" class="inline-flex items-center text-teal-600 hover:text-teal-700 font-medium group">
    <span>Learn More</span>
    <svg class="ml-2 h-4 w-4 transition-transform group-hover:translate-x-1" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
      <path fill-rule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clip-rule="evenodd"/>
    </svg>
  </a>
</div>
```

#### Provider Card

```html
<div class="bg-white rounded-xl shadow-lg hover:shadow-xl transition-shadow duration-200 overflow-hidden">
  <!-- Image with Overlay -->
  <div class="relative h-48">
    <img src="provider.jpg" alt="Dr. Jane Smith" class="w-full h-full object-cover">
    <div class="absolute inset-0 bg-gradient-to-t from-gray-900/40 via-gray-900/10 to-transparent"></div>
    <div class="absolute top-4 right-4 z-10">
      <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800">
        ✓ Verified
      </span>
    </div>
  </div>

  <!-- Content -->
  <div class="p-6">
    <h3 class="text-xl font-semibold text-gray-900 mb-1">Dr. Jane Smith</h3>
    <p class="text-sm text-gray-600 mb-4">Cardiologist • 15 years experience</p>

    <!-- Stats -->
    <div class="flex items-center gap-4 mb-4">
      <div class="flex items-center text-sm text-gray-600">
        <svg class="h-4 w-4 text-yellow-400 mr-1" fill="currentColor" viewBox="0 0 20 20" aria-hidden="true">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
        </svg>
        <span>4.9 (127 reviews)</span>
      </div>
      <div class="text-sm text-gray-600">
        $150/session
      </div>
    </div>

    <!-- CTA -->
    <button class="w-full bg-gradient-to-r from-teal-600 to-gray-700 hover:from-teal-700 hover:to-gray-800 text-white px-6 py-2 rounded-lg font-semibold transition-all duration-200">
      Book Appointment
    </button>
  </div>
</div>
```

#### Hero Section

```html
<section class="relative bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 py-24 overflow-hidden">
  <!-- Decorative Blobs -->
  <div class="absolute top-0 right-0 w-96 h-96 bg-teal-500/10 rounded-full blur-3xl animate-blob"></div>
  <div class="absolute bottom-0 left-0 w-96 h-96 bg-gray-700/10 rounded-full blur-3xl animate-blob animation-delay-2000"></div>

  <!-- Content -->
  <div class="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="text-center">
      <!-- Eyebrow -->
      <p class="text-teal-400 font-semibold mb-4 uppercase tracking-wide text-sm">
        Welcome to WellnessConnect
      </p>

      <!-- Heading -->
      <h1 class="text-5xl md:text-6xl font-bold text-white mb-6">
        Your Healthcare Journey
        <span class="block bg-gradient-to-r from-teal-400 to-white bg-clip-text text-transparent">
          Starts Here
        </span>
      </h1>

      <!-- Description -->
      <p class="text-xl text-gray-300 mb-8 max-w-3xl mx-auto">
        Connect with verified healthcare providers for virtual consultations, personalized care, and ongoing support.
      </p>

      <!-- CTAs -->
      <div class="flex flex-col sm:flex-row gap-4 justify-center">
        <button class="bg-white text-teal-600 px-8 py-3 rounded-lg font-bold hover:bg-gray-100 transition-all duration-200 shadow-lg hover:shadow-xl">
          Get Started
        </button>
        <button class="border-2 border-white text-white px-8 py-3 rounded-lg font-bold hover:bg-white hover:text-teal-600 transition-all duration-200">
          Learn More
        </button>
      </div>
    </div>
  </div>
</section>
```

---

## Maintenance & Updates

### Version Control

This design system follows semantic versioning:

- **Major version** (1.x.x): Breaking changes to color palette, component structure
- **Minor version** (x.1.x): New components, new patterns, non-breaking additions
- **Patch version** (x.x.1): Bug fixes, documentation updates, minor tweaks

**Current Version**: 1.0.0

### Adding New Components

When adding a new component to the design system:

1. **Design the Component**
   - Follow the established color palette
   - Use the spacing scale
   - Ensure WCAG 2.1 AA compliance
   - Test on mobile, tablet, and desktop

2. **Document the Component**
   - Add to the Component Library section
   - Provide HTML/ERB code example
   - Specify usage guidelines
   - Include accessibility notes

3. **Test the Component**
   - Keyboard navigation
   - Screen reader compatibility
   - Color contrast
   - Responsive behavior
   - Cross-browser compatibility

4. **Update the Design System**
   - Add component to this document
   - Update version number if needed
   - Commit changes to Git
   - Notify the team

### Updating Colors

If the brand colors need to change:

1. **Update Color Palette Section**
   - Update hex values in the color table
   - Update RGB values
   - Update usage descriptions

2. **Search and Replace**
   - Search for old Tailwind classes (e.g., `indigo-600`)
   - Replace with new classes (e.g., `teal-600`)
   - Test all pages after replacement

3. **Verify Contrast**
   - Check all color combinations
   - Ensure WCAG 2.1 AA compliance
   - Update contrast ratio table

4. **Update Documentation**
   - Update all code examples
   - Update screenshots if applicable
   - Increment version number

### Common Maintenance Tasks

#### Updating a Button Style

```html
<!-- Old -->
<button class="bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-2 rounded-lg">
  Button
</button>

<!-- New -->
<button class="bg-gradient-to-r from-teal-600 to-gray-700 hover:from-teal-700 hover:to-gray-800 text-white px-6 py-2 rounded-lg font-semibold transition-all duration-200 shadow-md hover:shadow-lg">
  Button
</button>
```

#### Updating a Link Style

```html
<!-- Old -->
<a href="#" class="text-indigo-600 hover:text-indigo-700">
  Link
</a>

<!-- New -->
<a href="#" class="text-teal-600 hover:text-teal-700 transition-colors duration-200">
  Link
</a>
```

#### Updating a Background

```html
<!-- Old -->
<section class="bg-gradient-to-r from-indigo-600 to-purple-600 py-16">
  <!-- Content -->
</section>

<!-- New -->
<section class="bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900 py-16">
  <!-- Content -->
</section>
```

### Design System Governance

**Ownership**: The design system is maintained by the frontend development team.

**Review Process**:
1. Propose changes via pull request
2. Review by at least one team member
3. Test on staging environment
4. Update documentation
5. Merge to main branch

**Communication**:
- Major changes announced in team meetings
- Documentation updates committed to Git
- Version changes noted in CHANGELOG.md

### Resources

- **Tailwind CSS Documentation**: https://tailwindcss.com/docs
- **WCAG 2.1 Guidelines**: https://www.w3.org/WAI/WCAG21/quickref/
- **Color Contrast Checker**: https://webaim.org/resources/contrastchecker/
- **Accessibility Testing**: https://wave.webaim.org/
- **Responsive Design Testing**: https://responsively.app/

---

## Conclusion

This design system ensures consistency, accessibility, and maintainability across the WellnessConnect platform. By following these guidelines, all developers and designers can create cohesive user experiences that align with our brand and serve our users effectively.

**Key Takeaways**:

1. **Use teal-600 as the primary brand color** for all interactive elements
2. **Use dark gradient backgrounds** for hero sections, CTAs, and footer
3. **Use white/light backgrounds** for forms, dashboards, and content pages
4. **Ensure WCAG 2.1 AA compliance** for all color combinations
5. **Follow the component patterns** for consistency
6. **Test for accessibility** with keyboard and screen readers
7. **Use responsive breakpoints** for mobile-first design
8. **Document all changes** and update this design system

**Questions or Suggestions?**

If you have questions about the design system or suggestions for improvements, please:
- Open an issue in the project repository
- Discuss in team meetings
- Propose changes via pull request

---

**Last Updated**: 2025-10-05
**Version**: 1.0.0
**Maintained by**: WellnessConnect Frontend Team
