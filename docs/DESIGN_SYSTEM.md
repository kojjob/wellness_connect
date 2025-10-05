# WellnessConnect Design System

## Overview
This document defines the design system for the WellnessConnect platform to ensure consistency across all pages and components.

**Last Updated**: 2025-10-05  
**Status**: ✅ Active  
**Version**: 1.0.0

---

## Color Palette

### Primary Colors

#### Teal (Primary Accent)
- **teal-50**: `#f0fdfa` - Hover backgrounds, light accents
- **teal-100**: `#ccfbf1` - Subtle backgrounds
- **teal-200**: `#99f6e4` - Section headings in dark backgrounds
- **teal-400**: `#2dd4bf` - Hover states, icons
- **teal-500**: `#14b8a6` - Gradient stops
- **teal-600**: `#0d9488` - **PRIMARY BRAND COLOR** - Buttons, links, icons
- **teal-700**: `#0f766e` - Hover states on buttons

#### Gray (Neutral)
- **white**: `#ffffff` - Backgrounds, text on dark
- **gray-50**: `#f9fafb` - Light backgrounds
- **gray-100**: `#f3f4f6` - Card backgrounds
- **gray-200**: `#e5e7eb` - Borders, dividers
- **gray-300**: `#d1d5db` - Secondary text on dark
- **gray-400**: `#9ca3af` - Placeholder text, disabled states
- **gray-600**: `#4b5563` - Secondary text
- **gray-700**: `#374151` - **SECONDARY BRAND COLOR** - Gradient stops, text
- **gray-800**: `#1f2937` - Dark backgrounds
- **gray-900**: `#111827` - **PRIMARY DARK** - Footer, dark sections, primary text

### Accent Colors

#### Success/Positive
- **green-500**: `#10b981` - Success messages, verified badges
- **green-600**: `#059669` - Success button hover

#### Warning/Attention
- **yellow-500**: `#f59e0b` - Warning messages
- **amber-500**: `#f59e0b` - Attention indicators

#### Error/Danger
- **red-500**: `#ef4444` - Error messages
- **red-600**: `#dc2626` - Error button hover, admin indicators

---

## Typography

### Font Family
```css
font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
```

### Font Sizes
- **text-xs**: 0.75rem (12px) - Small labels, badges
- **text-sm**: 0.875rem (14px) - Body text, links
- **text-base**: 1rem (16px) - Default body text
- **text-lg**: 1.125rem (18px) - Large body text
- **text-xl**: 1.25rem (20px) - Section subheadings
- **text-2xl**: 1.5rem (24px) - Card headings
- **text-3xl**: 1.875rem (30px) - Section headings
- **text-4xl**: 2.25rem (36px) - Page headings
- **text-5xl**: 3rem (48px) - Hero headings
- **text-6xl**: 3.75rem (60px) - Large hero headings

### Font Weights
- **font-normal**: 400 - Body text
- **font-medium**: 500 - Emphasized text
- **font-semibold**: 600 - Subheadings, buttons
- **font-bold**: 700 - Headings, important text
- **font-extrabold**: 800 - Hero headings

---

## Spacing System

### Padding/Margin Scale
- **1**: 0.25rem (4px)
- **2**: 0.5rem (8px)
- **3**: 0.75rem (12px)
- **4**: 1rem (16px)
- **5**: 1.25rem (20px)
- **6**: 1.5rem (24px)
- **8**: 2rem (32px)
- **10**: 2.5rem (40px)
- **12**: 3rem (48px)
- **16**: 4rem (64px)
- **20**: 5rem (80px)
- **24**: 6rem (96px)

### Common Spacing Patterns
- **Section Padding**: `py-16 md:py-24` (64px/96px mobile, 96px/144px desktop)
- **Card Padding**: `p-6 md:p-8` (24px/32px mobile, 32px/48px desktop)
- **Button Padding**: `px-6 py-2` (24px horizontal, 8px vertical)
- **Input Padding**: `px-4 py-2` (16px horizontal, 8px vertical)

---

## Components

### Buttons

#### Primary Button
```html
<button class="bg-gradient-to-r from-teal-600 to-gray-700 hover:from-teal-700 hover:to-gray-800 text-white px-6 py-2 rounded-lg text-sm font-semibold transition-all duration-200 shadow-md hover:shadow-lg">
  Button Text
</button>
```

#### Secondary Button
```html
<button class="text-gray-700 hover:text-teal-600 hover:bg-teal-50 px-6 py-2 rounded-lg text-sm font-medium transition-all duration-200">
  Button Text
</button>
```

#### Outline Button
```html
<button class="border-2 border-teal-600 text-teal-600 hover:bg-teal-600 hover:text-white px-6 py-2 rounded-lg text-sm font-semibold transition-all duration-200">
  Button Text
</button>
```

### Cards

#### Standard Card
```html
<div class="bg-white rounded-xl shadow-lg hover:shadow-xl transition-shadow duration-200 p-6">
  <!-- Card content -->
</div>
```

#### Card with Gradient Border
```html
<div class="bg-white rounded-xl shadow-lg p-6 ring-1 ring-gray-200 hover:ring-teal-500 transition-all duration-200">
  <!-- Card content -->
</div>
```

### Links

#### Standard Link
```html
<a href="#" class="text-teal-600 hover:text-teal-700 transition-colors duration-200">
  Link Text
</a>
```

#### Footer Link
```html
<a href="#" class="text-gray-300 hover:text-teal-400 transition-colors duration-200">
  Link Text
</a>
```

### Forms

#### Input Field
```html
<input type="text" 
       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent transition-all duration-200"
       placeholder="Enter text">
```

#### Textarea
```html
<textarea 
  class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent transition-all duration-200"
  rows="4"
  placeholder="Enter text"></textarea>
```

---

## Gradients

### Background Gradients
```css
/* Primary Gradient (Teal to Gray) */
bg-gradient-to-r from-teal-600 to-gray-700

/* Hero Gradient (Dark) */
bg-gradient-to-br from-gray-900 via-gray-800 to-teal-900

/* Light Gradient */
bg-gradient-to-br from-teal-50 to-white

/* Hover Gradient */
hover:from-teal-700 hover:to-gray-800
```

### Text Gradients
```css
/* Primary Text Gradient */
bg-gradient-to-r from-teal-600 to-gray-700 bg-clip-text text-transparent

/* Light Text Gradient */
bg-gradient-to-r from-teal-400 to-white bg-clip-text text-transparent
```

### Image Overlays
```css
/* Standard Overlay */
bg-gradient-to-t from-gray-900/40 via-gray-900/10 to-transparent

/* Dark Overlay */
bg-gradient-to-t from-gray-900/60 via-gray-900/20 to-transparent
```

---

## Shadows

### Shadow Scale
```css
/* Small */
shadow-sm

/* Medium (Default) */
shadow-md

/* Large */
shadow-lg

/* Extra Large */
shadow-xl

/* 2X Large */
shadow-2xl

/* Hover Effect */
hover:shadow-lg
```

---

## Border Radius

### Radius Scale
- **rounded-sm**: 0.125rem (2px) - Small elements
- **rounded**: 0.25rem (4px) - Default
- **rounded-md**: 0.375rem (6px) - Inputs
- **rounded-lg**: 0.5rem (8px) - **STANDARD** - Buttons, cards
- **rounded-xl**: 0.75rem (12px) - Large cards
- **rounded-2xl**: 1rem (16px) - Hero sections
- **rounded-full**: 9999px - Avatars, badges

---

## Transitions

### Standard Transitions
```css
/* All Properties */
transition-all duration-200

/* Colors Only */
transition-colors duration-200

/* Transform Only */
transition-transform duration-200

/* Shadow Only */
transition-shadow duration-200
```

### Hover Effects
```css
/* Scale Up */
hover:scale-105 transition-transform duration-200

/* Translate */
group-hover:translate-x-1 transition-transform

/* Opacity */
group-hover:opacity-100 transition-opacity
```

---

## Accessibility

### Focus States
All interactive elements must have visible focus states:
```css
focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2
```

### ARIA Labels
All icons and interactive elements without visible text must have ARIA labels:
```html
<button aria-label="Close menu">
  <svg aria-hidden="true">...</svg>
</button>
```

### Color Contrast
- **Normal Text**: Minimum 4.5:1 contrast ratio
- **Large Text**: Minimum 3:1 contrast ratio
- **Interactive Elements**: Minimum 3:1 contrast ratio

### Touch Targets
- **Minimum Size**: 44px × 44px on mobile
- **Recommended**: 48px × 48px

---

## Responsive Design

### Breakpoints
```css
/* Mobile First */
/* Default: < 640px */

/* Small (sm): ≥ 640px */
sm:

/* Medium (md): ≥ 768px */
md:

/* Large (lg): ≥ 1024px */
lg:

/* Extra Large (xl): ≥ 1280px */
xl:

/* 2X Large (2xl): ≥ 1536px */
2xl:
```

### Common Responsive Patterns
```css
/* Text Size */
text-2xl md:text-3xl lg:text-4xl

/* Padding */
py-12 md:py-16 lg:py-24

/* Grid Columns */
grid-cols-1 md:grid-cols-2 lg:grid-cols-3

/* Flex Direction */
flex-col md:flex-row
```

---

## Icons

### Icon Sizes
- **h-4 w-4**: 16px - Small inline icons
- **h-5 w-5**: 20px - Standard icons
- **h-6 w-6**: 24px - Large icons
- **h-8 w-8**: 32px - Logo, large icons

### Icon Colors
- **Primary**: `text-teal-600`
- **Hover**: `group-hover:text-teal-700`
- **On Dark**: `text-teal-400`
- **Disabled**: `text-gray-400`

---

## Animation Classes

### Custom Animations (in application.css)
```css
/* Blob Animation */
@keyframes blob {
  0%, 100% { transform: translate(0, 0) scale(1); }
  25% { transform: translate(20px, -50px) scale(1.1); }
  50% { transform: translate(-20px, 20px) scale(0.9); }
  75% { transform: translate(50px, 50px) scale(1.05); }
}

/* Float Animation */
@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}

/* Pulse Subtle */
@keyframes pulse-subtle {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.8; }
}

/* Gradient Animation */
@keyframes gradient {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}
```

---

## Usage Guidelines

### When to Use Teal
- Primary CTAs and action buttons
- Links and interactive elements
- Icons representing positive actions
- Brand elements (logo, headings)
- Hover states
- Focus indicators

### When to Use Gray
- Body text and content
- Backgrounds and containers
- Borders and dividers
- Secondary buttons
- Disabled states
- Gradient combinations with teal

### When to Use White
- Page backgrounds
- Card backgrounds
- Text on dark backgrounds
- Spacing and breathing room

---

## Maintenance

### Adding New Components
1. Follow the established color palette
2. Use consistent spacing from the spacing system
3. Apply standard transitions (200ms duration)
4. Ensure WCAG 2.1 AA accessibility compliance
5. Test on mobile, tablet, and desktop
6. Document in this design system

### Updating Colors
If the brand colors need to change:
1. Update the color palette section above
2. Search and replace across all files
3. Test all components for contrast compliance
4. Update documentation

---

## Resources

- **Tailwind CSS Documentation**: https://tailwindcss.com/docs
- **WCAG Guidelines**: https://www.w3.org/WAI/WCAG21/quickref/
- **Color Contrast Checker**: https://webaim.org/resources/contrastchecker/

---

**This design system should be followed for all new features and updates to ensure consistency across the WellnessConnect platform.**

