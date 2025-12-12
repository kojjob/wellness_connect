module AvatarHelper
  # Render user avatar with consistent styling
  #
  # @param user [User] The user object
  # @param size [Symbol] Avatar size (:small, :medium, :large, :xlarge)
  # @param shape [Symbol] Avatar shape (:rounded, :circle)
  # @param show_ring [Boolean] Whether to show ring decoration
  # @param show_status [Boolean] Whether to show online status indicator
  # @param additional_classes [String] Additional CSS classes
  # @return [String] HTML for the avatar
  def render_user_avatar(user, size: :medium, shape: :rounded, show_ring: false, show_status: false, additional_classes: "")
    render partial: "shared/user_avatar",
           locals: {
             user: user,
             size: size,
             shape: shape,
             show_ring: show_ring,
             show_status: show_status,
             additional_classes: additional_classes
           }
  end

  # Get avatar size in pixels for inline styles
  # @param size [Symbol] Avatar size
  # @return [Integer] Size in pixels
  def avatar_size_px(size)
    case size
    when :small then 32
    when :medium then 48
    when :large then 64
    when :xlarge then 96
    else 48
    end
  end

  # Get avatar gradient classes based on user role
  # @param user [User] The user object
  # @return [String] Tailwind gradient classes
  def avatar_gradient_for_user(user)
    user.avatar_gradient_classes
  end

  # Get user initials
  # @param user [User] The user object
  # @return [String] User initials
  def user_initials(user)
    user.initials
  end
end
