# Hero Section Image Documentation

## Current Implementation

### Image Source
- **Provider**: Unsplash
- **Image ID**: photo-1576091160399-112ba8d25d1d
- **Subject**: Healthcare professional in modern office setting
- **License**: Unsplash License (Free to use)

### Image Details
- **Description**: Professional healthcare provider working on laptop in a warm, well-lit modern office environment
- **Dimensions**: 800x1000px (optimized for hero section)
- **Format**: WebP (primary) with JPG fallback
- **Quality**: 80% (balanced quality/performance)
- **Loading**: Lazy loading enabled for performance

### Technical Implementation

```erb
<picture>
  <!-- WebP format for modern browsers -->
  <source 
    srcset="https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&h=1000&fit=crop&q=80&fm=webp" 
    type="image/webp">
  <!-- JPG fallback -->
  <img 
    src="https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&h=1000&fit=crop&q=80" 
    alt="Healthcare professional providing virtual consultation in a modern, welcoming office environment with laptop and warm lighting"
    class="w-full h-full object-cover"
    loading="lazy"
    width="800"
    height="1000">
</picture>
```

### Accessibility Features
- **Alt Text**: Descriptive alt text for screen readers
- **Semantic HTML**: Uses `<picture>` element for responsive images
- **Dimensions**: Explicit width/height to prevent layout shift
- **Loading Strategy**: Lazy loading to improve initial page load

### Visual Enhancements
- **Gradient Overlays**: 
  - Bottom gradient: `from-indigo-900/40 via-transparent to-transparent`
  - Corner vignette: `from-transparent via-transparent to-indigo-900/20`
- **Purpose**: Adds depth and ensures floating cards remain readable

## Alternative Image Options

If you want to replace the current image, here are recommended alternatives from Unsplash:

### Option 1: Female Healthcare Professional
```
https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=800&h=1000&fit=crop&q=80
```
- Subject: Female doctor with stethoscope in modern clinic
- Vibe: Professional, approachable, clinical

### Option 2: Telehealth Consultation
```
https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&h=1000&fit=crop&q=80
```
- Subject: Healthcare provider during video consultation
- Vibe: Modern, technology-focused, virtual care

### Option 3: Diverse Healthcare Team
```
https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=800&h=1000&fit=crop&q=80
```
- Subject: Diverse medical team in hospital setting
- Vibe: Collaborative, inclusive, professional

### Option 4: Wellness Coach Setting
```
https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=800&h=1000&fit=crop&q=80
```
- Subject: Wellness professional in bright, natural setting
- Vibe: Holistic, wellness-focused, approachable

## Using Custom Images

### For Production Use

1. **Self-hosted Images** (Recommended for production):
   ```erb
   <%= image_tag "hero/healthcare-professional.webp", 
       alt: "Healthcare professional providing virtual consultation",
       class: "w-full h-full object-cover",
       loading: "lazy" %>
   ```

2. **Place images in**: `app/assets/images/hero/`

3. **Optimize images before upload**:
   - Use WebP format (with JPG fallback)
   - Compress to 80% quality
   - Resize to appropriate dimensions (800-1200px width)
   - Use tools like ImageOptim, Squoosh, or TinyPNG

### Image Requirements

- **Aspect Ratio**: 4:5 or 3:4 (portrait orientation)
- **Minimum Resolution**: 800x1000px
- **Recommended Resolution**: 1200x1500px (for retina displays)
- **File Size**: < 200KB (WebP), < 400KB (JPG)
- **Subject Matter**: 
  - Healthcare professional in modern setting
  - Warm, inviting lighting
  - Technology visible (laptop, tablet, video call)
  - Professional but approachable demeanor
  - Diverse representation preferred

### CDN Integration (Optional)

For better performance, consider using a CDN:

```erb
<%= image_tag "https://cdn.yoursite.com/images/hero-healthcare.webp",
    alt: "Healthcare professional providing virtual consultation",
    class: "w-full h-full object-cover",
    loading: "lazy" %>
```

## Performance Considerations

### Current Performance
- **WebP Format**: ~40% smaller than JPG
- **Lazy Loading**: Image loads only when visible
- **Optimized Quality**: 80% quality balances size/clarity
- **Unsplash CDN**: Fast global delivery

### Monitoring
- Use Lighthouse to check image performance
- Target: < 2.5s LCP (Largest Contentful Paint)
- Monitor Core Web Vitals in production

## Attribution

Current image from Unsplash:
- **Photographer**: National Cancer Institute
- **License**: Unsplash License (https://unsplash.com/license)
- **No attribution required** but appreciated

## Future Improvements

1. **Responsive Images**: Add multiple sizes for different viewports
2. **Art Direction**: Different images for mobile vs desktop
3. **Blur Placeholder**: Add blur-up effect while loading
4. **Custom Photography**: Commission professional photos for brand consistency

