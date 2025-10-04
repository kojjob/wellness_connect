# Toast/Flash Notification System Usage Guide

## Overview

A comprehensive, modern toast notification system for WellnessConnect with:

- ✅ 5 notification types (success, error, warning, info, notice)
- ✅ Auto-dismiss after 5 seconds (customizable)
- ✅ Manual dismiss with close button
- ✅ Smooth entrance/exit animations
- ✅ Multiple toasts stack vertically
- ✅ Pause auto-dismiss on hover
- ✅ Full Hotwire/Turbo integration
- ✅ Accessible (ARIA attributes)
- ✅ Mobile responsive

## Basic Usage in Controllers

### Standard Flash Messages

```ruby
class PostsController < ApplicationController
  def create
    @post = Post.new(post_params)

    if @post.save
      flash[:success] = "Post created successfully!"
      redirect_to @post
    else
      flash[:error] = "Failed to create post"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    flash[:warning] = "Post has been deleted"
    redirect_to posts_path
  end
end
```

### Available Flash Types

- **`:success`** - Green toast for successful actions
- **`:error`** / **`:alert`** - Red toast for errors
- **`:warning`** - Yellow toast for warnings
- **`:info`** - Blue toast for informational messages
- **`:notice`** - Gray toast for general notices

### Turbo Stream Flash Messages

For dynamic flash messages in Turbo Frame/Stream responses:

```ruby
class CommentsController < ApplicationController
  def create
    @comment = Comment.new(comment_params)

    respond_to do |format|
      if @comment.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("comments", @comment),
            turbo_stream_flash(:success, "Comment added!")
          ]
        end
      else
        format.turbo_stream do
          render_turbo_flash(:error, "Failed to add comment")
        end
      end
    end
  end
end
```

## Helper Methods

### `turbo_stream_flash(type, message)`

Returns a Turbo Stream action that appends a toast:

```ruby
turbo_stream_flash(:success, "Record saved!")
```

### `render_turbo_flash(type, message)`

Renders a Turbo Stream response with a flash message:

```ruby
respond_to do |format|
  format.turbo_stream { render_turbo_flash(:success, "Done!") }
end
```

### `toast_html(type, message)`

Generates toast HTML for manual insertion:

```ruby
<%= toast_html(:info, "Welcome back!") %>
```

## Customization

### Auto-Dismiss Duration

Change the auto-dismiss timer by modifying the data attribute:

```erb
<%# In your partial if you need custom duration %>
<div data-controller="toast"
     data-toast-duration-value="3000">  <%# 3 seconds instead of 5 %>
  ...
</div>
```

### Disable Auto-Dismiss

```erb
<div data-controller="toast"
     data-toast-auto-dismiss-value="false">
  ...
</div>
```

## Examples

### Multiple Flash Messages

```ruby
def complex_action
  flash[:success] = "Primary action completed"
  flash[:info] = "Additional info: Check your email"
  flash[:warning] = "Note: This expires in 24 hours"
  redirect_to root_path
end
```

All three toasts will stack vertically in the top-right corner.

### Conditional Flash

```ruby
def update
  if @user.update(user_params)
    if @user.premium?
      flash[:success] = "Premium profile updated!"
    else
      flash[:success] = "Profile updated successfully"
      flash[:info] = "Upgrade to premium for more features"
    end
    redirect_to @user
  else
    flash.now[:error] = "Update failed: #{@user.errors.full_messages.join(', ')}"
    render :edit
  end
end
```

### Integration with Devise

Already integrated! Devise flash messages (`:notice`, `:alert`) will automatically use the toast system.

```ruby
# In Devise controllers, these work automatically:
flash[:notice] = "Signed in successfully"
flash[:alert] = "Invalid email or password"
```

## Styling

Toast styles are defined in:
- `app/assets/tailwind/application.css` - Animation CSS
- `app/views/shared/_toast.html.erb` - Component structure and TailwindCSS classes

### Color Schemes

| Type    | Background  | Border    | Text      | Icon      |
|---------|------------|-----------|-----------|-----------|
| success | Green 50   | Green 500 | Green 800 | Green 500 |
| error   | Red 50     | Red 500   | Red 800   | Red 500   |
| warning | Yellow 50  | Yellow 500| Yellow 800| Yellow 500|
| info    | Blue 50    | Blue 500  | Blue 800  | Blue 500  |
| notice  | Gray 50    | Gray 500  | Gray 800  | Gray 500  |

## Accessibility

- **ARIA**: `role="alert"` and `aria-live="polite"` for screen readers
- **Keyboard**: Close button is keyboard accessible
- **Focus**: Dismiss button can be focused and activated with Enter/Space
- **Contrast**: All color combinations meet WCAG AA standards

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- Mobile browsers (iOS Safari, Chrome Mobile)
- Requires JavaScript enabled

## Testing

System tests are available in `test/system/flash_messages_test.rb`:

```bash
bin/rails test test/system/flash_messages_test.rb
```

## Files

- `app/views/shared/_flash.html.erb` - Main flash container
- `app/views/shared/_toast.html.erb` - Individual toast component
- `app/javascript/controllers/toast_controller.js` - Stimulus controller
- `app/assets/tailwind/application.css` - Toast animations
- `app/helpers/application_helper.rb` - Helper methods
- `test/system/flash_messages_test.rb` - System tests
