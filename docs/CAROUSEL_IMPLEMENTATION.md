# Healthcare Services Carousel Implementation

## ✅ Overview

The "Explore Healthcare Services" section has been transformed into an interactive, responsive carousel featuring 7 healthcare service categories with high-quality background images.

## 🎨 Design Features

### Visual Design
- **Card Layout**: Full-height cards (h-96) with background images
- **Image Overlay**: Dark gradient overlays for text readability
- **Glass Morphism**: Translucent icon containers with backdrop blur
- **Hover Effects**: Scale up (105%) with enhanced shadows
- **Smooth Transitions**: 500ms cubic-bezier animations
- **Responsive Images**: WebP format with JPG fallback

### Service Categories (7 Total)

1. **Mental Health**
   - Image: Therapy/wellness consultation
   - Providers: 850+
   - Color: Gray gradient overlay

2. **Wellness & Nutrition**
   - Image: Healthy food/nutrition
   - Providers: 1,200+
   - Color: Emerald gradient overlay

3. **Primary Care**
   - Image: Doctor consultation
   - Providers: 650+
   - Color: Blue gradient overlay

4. **Specialty Care**
   - Image: Medical specialist
   - Providers: 950+
   - Color: Purple gradient overlay

5. **Physical Therapy**
   - Image: PT session
   - Providers: 420+
   - Color: Teal gradient overlay

6. **Dermatology**
   - Image: Skin care consultation
   - Providers: 380+
   - Color: Pink gradient overlay

7. **Pediatric Care**
   - Image: Child healthcare
   - Providers: 520+
   - Color: Indigo gradient overlay

## 🎯 Carousel Features

### Navigation
- **Desktop**: Previous/Next arrow buttons (left/right)
- **Mobile**: Touch/swipe gestures
- **Keyboard**: Arrow keys, Home, End
- **Pagination**: Dot indicators at bottom

### Responsive Behavior
- **Desktop (lg+)**: Shows 4 cards at once
- **Tablet (md-lg)**: Shows 2 cards at once
- **Mobile (<md)**: Shows 1 card at once

### Interactions
- **Hover**: Pause autoplay (if enabled)
- **Touch**: Swipe left/right to navigate
- **Click**: Pagination dots for direct navigation
- **Keyboard**: Full keyboard navigation support

## 🛠️ Technical Implementation

### Stimulus Controller
**File**: `app/javascript/controllers/carousel_controller.js`

**Targets**:
- `container`: The sliding track
- `slide`: Individual carousel items
- `prevButton`: Previous navigation button
- `nextButton`: Next navigation button
- `indicator`: Pagination dots

**Values**:
```javascript
{
  index: 0,                    // Current slide index
  autoplay: false,             // Auto-advance slides
  interval: 5000,              // Autoplay interval (ms)
  slidesToShow: 4,             // Desktop slides visible
  slidesToShowTablet: 2,       // Tablet slides visible
  slidesToShowMobile: 1        // Mobile slides visible
}
```

**Key Methods**:
- `next()`: Navigate to next slide
- `previous()`: Navigate to previous slide
- `goToSlide(event)`: Jump to specific slide
- `updateCarousel()`: Update position and UI
- `handleTouchStart/Move/End()`: Touch gesture handling
- `handleKeydown()`: Keyboard navigation
- `startAutoplay()`: Begin auto-advance
- `stopAutoplay()`: Stop auto-advance

### HTML Structure
```erb
<div data-controller="carousel" 
     data-carousel-autoplay-value="false"
     data-carousel-slides-to-show-value="4">
  
  <!-- Navigation Buttons -->
  <button data-carousel-target="prevButton" 
          data-action="click->carousel#previous">
  </button>
  
  <!-- Carousel Track -->
  <div data-carousel-target="container">
    <div data-carousel-target="slide">
      <!-- Card content -->
    </div>
  </div>
  
  <!-- Pagination Indicators -->
  <button data-carousel-target="indicator"
          data-action="click->carousel#goToSlide">
  </button>
</div>
```

### CSS Utilities
**File**: `app/assets/tailwind/application.css`

```css
/* Line clamp for text truncation */
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* Carousel smooth scrolling */
.carousel-container {
  scroll-behavior: smooth;
  -webkit-overflow-scrolling: touch;
}

/* Hide scrollbar */
.carousel-container::-webkit-scrollbar {
  display: none;
}
```

## ♿ Accessibility Features

### WCAG 2.1 AA Compliance
- ✅ **ARIA Labels**: All interactive elements labeled
- ✅ **Keyboard Navigation**: Full keyboard support
- ✅ **Focus Management**: Visible focus states
- ✅ **Screen Reader**: Semantic HTML with roles
- ✅ **Reduced Motion**: Respects `prefers-reduced-motion`
- ✅ **Color Contrast**: White text on dark overlays (>7:1)

### Keyboard Shortcuts
- `←` Arrow Left: Previous slide
- `→` Arrow Right: Next slide
- `Home`: First slide
- `End`: Last slide
- `Tab`: Navigate through controls

### ARIA Attributes
```html
role="region"
aria-label="Healthcare service categories carousel"
role="list"
role="listitem"
role="tablist"
role="tab"
aria-selected="true/false"
```

## 📱 Responsive Design

### Breakpoints
```css
/* Mobile: < 768px */
w-full (100% width per slide)

/* Tablet: 768px - 1023px */
w-[calc(50%-12px)] (2 slides visible)

/* Desktop: ≥ 1024px */
w-[calc(25%-18px)] (4 slides visible)
```

### Touch Gestures
- **Swipe Left**: Next slide
- **Swipe Right**: Previous slide
- **Swipe Threshold**: 50px minimum

## 🚀 Performance Optimizations

### Image Loading
- **Lazy Loading**: `loading="lazy"` on all images
- **WebP Format**: Modern format with fallback
- **Optimized Size**: 600x800px at 80% quality
- **CDN Delivery**: Unsplash CDN for fast loading

### Animation Performance
- **GPU Acceleration**: `transform` instead of `left/right`
- **Reduced Motion**: Instant transitions if preferred
- **Debounced Resize**: Efficient window resize handling
- **Passive Listeners**: Touch events marked passive

### Expected Metrics
- **LCP**: < 2.5s (Largest Contentful Paint)
- **FID**: < 100ms (First Input Delay)
- **CLS**: < 0.1 (Cumulative Layout Shift)

## 🎨 Customization Options

### Enable Autoplay
```erb
data-carousel-autoplay-value="true"
data-carousel-interval-value="5000"
```

### Adjust Slides Visible
```erb
data-carousel-slides-to-show-value="3"
data-carousel-slides-to-show-tablet-value="2"
data-carousel-slides-to-show-mobile-value="1"
```

### Change Starting Slide
```erb
data-carousel-index-value="2"
```

## 🖼️ Image Sources

All images from Unsplash (free license):

1. **Mental Health**: `photo-1573497019940-1c28c88b4f3e`
2. **Wellness & Nutrition**: `photo-1490645935967-10de6ba17061`
3. **Primary Care**: `photo-1559839734-2b71ea197ec2`
4. **Specialty Care**: `photo-1631217868264-e5b90bb7e133`
5. **Physical Therapy**: `photo-1576091160550-2173dba999ef`
6. **Dermatology**: `photo-1612349317150-e413f6a5b16d`
7. **Pediatric Care**: `photo-1581594549595-35f6edc7b762`

### Replacing Images
To use custom images:

1. **Self-hosted**:
```erb
<%= image_tag "categories/mental-health.webp", 
    alt: "Mental health therapy session",
    class: "absolute inset-0 w-full h-full object-cover" %>
```

2. **Update Unsplash ID**:
```html
https://images.unsplash.com/photo-YOUR-ID-HERE?w=600&h=800&fit=crop&q=80
```

## 🧪 Testing Checklist

- [ ] Desktop: 4 slides visible, navigation works
- [ ] Tablet: 2 slides visible, navigation works
- [ ] Mobile: 1 slide visible, swipe works
- [ ] Keyboard: All shortcuts functional
- [ ] Screen Reader: Announces slides correctly
- [ ] Reduced Motion: No animations
- [ ] Touch: Swipe gestures responsive
- [ ] Pagination: Dots update correctly
- [ ] Hover: Autoplay pauses (if enabled)
- [ ] Images: Load properly with fallbacks
- [ ] Performance: Smooth 60fps animations

## 🐛 Troubleshooting

### Carousel not sliding
- Check Stimulus controller is connected
- Verify `data-carousel-target="container"` exists
- Ensure slides have `data-carousel-target="slide"`

### Images not loading
- Check internet connection (using Unsplash CDN)
- Verify image URLs are correct
- Check browser console for errors

### Touch gestures not working
- Ensure touch events are registered
- Check swipe threshold (50px minimum)
- Verify passive event listeners

### Buttons disabled
- Check if at first/last slide
- Verify button targets are set
- Ensure `updateButtons()` is called

## 📚 Related Files

- `app/views/home/index.html.erb` (lines 143-525)
- `app/javascript/controllers/carousel_controller.js`
- `app/assets/tailwind/application.css` (lines 118-158)
- `docs/HERO_IMAGE.md` (image guidelines)

## 🔄 Future Enhancements

1. **Infinite Loop**: Wrap around to first slide
2. **Thumbnail Preview**: Show mini previews
3. **Video Support**: Add video backgrounds
4. **Analytics**: Track slide interactions
5. **Deep Linking**: URL-based slide selection
6. **Preloading**: Preload adjacent slides
7. **Vertical Carousel**: Support vertical scrolling
8. **Custom Transitions**: More animation options

