# Dropdown Testing Guide

## Quick Test Checklist

### ✅ **Notification Dropdown (Authenticated Users Only)**

1. **Sign in to the application**
   - Visit http://localhost:3000
   - Sign in with any user account

2. **Locate the notification bell icon**
   - Look for the bell icon in the top-right navbar
   - Should be visible on desktop (≥ 768px width)

3. **Test dropdown open**
   - Click the bell icon
   - Dropdown should appear below the icon
   - Should show "No notifications yet" if no notifications exist
   - Console should log: "Dropdown controller connected"

4. **Test dropdown close**
   - **Click outside**: Click anywhere outside the dropdown → should close
   - **Escape key**: Press Escape key → should close and focus returns to button
   - **Click bell again**: Click bell icon again → should toggle closed

5. **Test with notifications**
   - Book an appointment to generate notifications
   - Click bell icon → should show notification list
   - Click a notification → should mark as read and navigate to action URL

---

### ✅ **User Profile Dropdown (Authenticated Users Only)**

1. **Locate the user avatar**
   - Look for the circular avatar with your email initial
   - Should be next to the notification bell

2. **Test dropdown open**
   - Click the avatar
   - Dropdown should appear below showing:
     - Email address
     - Account type (Provider/Patient)
     - Dashboard link
     - Sign Out button

3. **Test dropdown close**
   - **Click outside**: Click anywhere outside → should close
   - **Escape key**: Press Escape → should close
   - **Click avatar again**: Should toggle closed

4. **Test navigation**
   - Click "My Dashboard" → should navigate to dashboard
   - Dropdown should remain functional after navigation

---

### ✅ **Mobile Menu (All Users)**

1. **Resize browser to mobile width**
   - Use browser DevTools (F12)
   - Toggle device toolbar (Ctrl+Shift+M / Cmd+Shift+M)
   - Select iPhone or set width < 768px

2. **Locate hamburger menu**
   - Look for three horizontal lines icon in top-right
   - Desktop navigation should be hidden

3. **Test menu open**
   - Click hamburger icon
   - Menu should slide down/appear
   - Hamburger icon should change to X (close icon)
   - Body scroll should be disabled
   - Console should log: "Navbar controller connected"

4. **Test menu close**
   - **Click X icon**: Menu should close
   - **Click a link**: Menu should auto-close
   - **Resize to desktop**: Menu should auto-close

5. **Test authenticated mobile menu**
   - Sign in
   - Open mobile menu
   - Should show:
     - User avatar and email
     - Notifications link with count
     - Dashboard link
     - Sign Out button

---

## Troubleshooting

### Issue: Dropdown doesn't open when clicked

**Possible Causes:**
1. Stimulus controllers not loaded
2. JavaScript errors in console
3. Missing `data-controller="dropdown"` attribute

**Solutions:**
```bash
# Check browser console for errors
# Should see: "Dropdown controller connected"

# Verify Stimulus is loaded
# In browser console, run:
window.Stimulus

# Should return Stimulus application object
```

**Check HTML:**
```html
<!-- Dropdown wrapper should have data-controller -->
<div class="relative" data-controller="dropdown">
  <button data-dropdown-target="button" data-action="click->dropdown#toggle">
    <!-- Button content -->
  </button>
  <div data-dropdown-target="menu" class="hidden">
    <!-- Dropdown content -->
  </div>
</div>
```

---

### Issue: Dropdown doesn't close when clicking outside

**Possible Causes:**
1. Event listeners not attached
2. JavaScript error preventing event binding

**Solutions:**
```javascript
// Check in browser console
// Open dropdown, then run:
document.addEventListener('click', (e) => console.log('Click detected', e.target))

// Click outside dropdown - should log click events
```

---

### Issue: Escape key doesn't close dropdown

**Possible Causes:**
1. Keyboard event listener not attached
2. Focus is on another element

**Solutions:**
```javascript
// Check in browser console
document.addEventListener('keydown', (e) => console.log('Key pressed:', e.key))

// Press Escape - should log "Key pressed: Escape"
```

---

### Issue: Mobile menu doesn't close on link click

**Possible Causes:**
1. Missing `data-action="click->navbar#handleLinkClick"` on links
2. Navbar controller not connected

**Solutions:**
```html
<!-- Mobile menu links should have data-action -->
<%= link_to "Browse Providers", providers_path,
    data: { action: "click->navbar#handleLinkClick" },
    class: "..." %>
```

---

### Issue: Console shows "Stimulus controller not found"

**Possible Causes:**
1. Controller file not in correct directory
2. Filename doesn't match convention
3. Import map not configured

**Solutions:**
```bash
# Verify controller files exist
ls app/javascript/controllers/

# Should show:
# dropdown_controller.js
# navbar_controller.js

# Restart Rails server
bin/rails server
```

---

## Browser Console Commands

### Check if Stimulus is loaded:
```javascript
window.Stimulus
// Should return: Application {router: Router, ...}
```

### Check registered controllers:
```javascript
window.Stimulus.router.modulesByIdentifier
// Should include: "dropdown", "navbar"
```

### Manually trigger dropdown:
```javascript
// Find dropdown element
const dropdown = document.querySelector('[data-controller="dropdown"]')

// Get controller instance
const controller = window.Stimulus.getControllerForElementAndIdentifier(dropdown, 'dropdown')

// Manually open
controller.open()

// Manually close
controller.close()
```

### Check event listeners:
```javascript
// Monitor all clicks
document.addEventListener('click', (e) => {
  console.log('Clicked:', e.target)
})

// Monitor all keyboard events
document.addEventListener('keydown', (e) => {
  console.log('Key:', e.key)
})
```

---

## Expected Console Output

When page loads:
```
Dropdown controller connected
Dropdown controller connected  (if multiple dropdowns)
Navbar controller connected
```

When clicking dropdown button:
```
(No additional logs - dropdown should just open)
```

When clicking outside:
```
(No additional logs - dropdown should just close)
```

---

## Visual Indicators

### Dropdown Open State:
- ✅ Menu is visible (not hidden)
- ✅ Button has `aria-expanded="true"`
- ✅ Menu has `block` class, no `hidden` class

### Dropdown Closed State:
- ✅ Menu is hidden
- ✅ Button has `aria-expanded="false"`
- ✅ Menu has `hidden` class, no `block` class

### Mobile Menu Open State:
- ✅ Menu is visible
- ✅ Hamburger icon is hidden
- ✅ Close (X) icon is visible
- ✅ Body scroll is disabled (`overflow: hidden`)
- ✅ Button has `aria-expanded="true"`

### Mobile Menu Closed State:
- ✅ Menu is hidden
- ✅ Hamburger icon is visible
- ✅ Close (X) icon is hidden
- ✅ Body scroll is enabled
- ✅ Button has `aria-expanded="false"`

---

## Accessibility Testing

### Keyboard Navigation:
1. **Tab** through navbar elements
2. **Enter** or **Space** to open dropdown
3. **Escape** to close dropdown
4. **Tab** to navigate within dropdown
5. Focus should return to button after closing

### Screen Reader Testing:
1. Use NVDA (Windows) or VoiceOver (Mac)
2. Navigate to dropdown button
3. Should announce: "Button, [Button Text], collapsed"
4. Activate button
5. Should announce: "Button, [Button Text], expanded"
6. Should announce dropdown content

---

## Performance Checks

### Page Load:
- Controllers should connect within 100ms
- No JavaScript errors in console
- No layout shift when controllers load

### Dropdown Open/Close:
- Should be instant (< 50ms)
- Smooth transitions if CSS transitions are applied
- No lag or jank

### Mobile Menu:
- Should open/close smoothly
- No scroll issues
- No layout shift

---

## Success Criteria

✅ **All dropdowns open on click**  
✅ **All dropdowns close on click outside**  
✅ **All dropdowns close on Escape key**  
✅ **Mobile menu toggles correctly**  
✅ **Mobile menu closes on link click**  
✅ **Mobile menu closes on window resize**  
✅ **No JavaScript errors in console**  
✅ **ARIA attributes update correctly**  
✅ **Keyboard navigation works**  
✅ **Screen readers announce states correctly**

---

**Last Updated:** 2025-10-04  
**Version:** 1.0.0

