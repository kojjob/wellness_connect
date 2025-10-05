module ImageHelper
  # Generate responsive image tag with multiple sizes
  def responsive_image_tag(source, alt:, sizes: nil, **options)
    default_sizes = sizes || "(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
    
    image_tag(source, 
      alt: alt,
      loading: "lazy",
      sizes: default_sizes,
      **options
    )
  end

  # Generate picture tag with WebP support
  def picture_tag(source, alt:, **options)
    webp_source = source.gsub(/\.(jpg|jpeg|png)$/i, '.webp')
    
    content_tag(:picture) do
      concat tag(:source, srcset: webp_source, type: "image/webp")
      concat tag(:source, srcset: source, type: "image/#{File.extname(source)[1..-1]}")
      concat image_tag(source, alt: alt, loading: "lazy", **options)
    end
  end

  # Generate Unsplash image URL with optimizations
  def unsplash_image_url(photo_id, width: 800, height: 600, quality: 80, format: 'auto')
    "https://images.unsplash.com/#{photo_id}?w=#{width}&h=#{height}&q=#{quality}&fm=#{format}&fit=crop"
  end

  # Generate optimized Unsplash image tag
  def unsplash_image_tag(photo_id, alt:, width: 800, height: 600, **options)
    url = unsplash_image_url(photo_id, width: width, height: height)
    responsive_image_tag(url, alt: alt, **options)
  end

  # Generate srcset for responsive images
  def generate_srcset(base_url, widths: [320, 640, 960, 1280, 1920])
    widths.map do |width|
      "#{base_url}?w=#{width} #{width}w"
    end.join(", ")
  end

  # Lazy load image with blur-up effect
  def lazy_image_tag(source, alt:, **options)
    # Generate tiny placeholder (10px width)
    placeholder = source.include?('unsplash') ? "#{source}&w=10&blur=10" : source
    
    image_tag(placeholder,
      alt: alt,
      data: {
        src: source,
        controller: "lazy-image"
      },
      class: "blur-sm transition-all duration-300 #{options[:class]}",
      **options.except(:class)
    )
  end

  # Avatar image with fallback to initials
  def avatar_image_tag(user, size: 40, **options)
    if user.avatar.attached?
      image_tag(user.avatar.variant(resize_to_limit: [size, size]),
        alt: user.name,
        class: "rounded-full #{options[:class]}",
        **options.except(:class)
      )
    else
      content_tag(:div,
        user.initials,
        class: "rounded-full bg-gradient-to-br from-indigo-500 to-purple-500 text-white font-bold flex items-center justify-center #{options[:class]}",
        style: "width: #{size}px; height: #{size}px; font-size: #{size / 2.5}px",
        **options.except(:class)
      )
    end
  end
end

