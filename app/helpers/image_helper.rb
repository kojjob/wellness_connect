module ImageHelper
  # Generate responsive image tag with WebP support and lazy loading
  def responsive_image_tag(src, alt:, sizes: nil, loading: "lazy", css_class: nil, width: nil, height: nil)
    # For Unsplash images, we can use their API to get different formats
    base_url = src.split('?').first
    params = extract_params(src)
    
    # Generate srcset for different sizes
    srcset = generate_srcset(base_url, params)
    
    # Default sizes if not provided
    sizes ||= "(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
    
    image_tag(
      src,
      alt: alt,
      loading: loading,
      class: css_class,
      srcset: srcset,
      sizes: sizes,
      width: width,
      height: height,
      decoding: "async"
    )
  end

  # Generate picture tag with WebP support
  def picture_tag(src, alt:, loading: "lazy", css_class: nil, width: nil, height: nil)
    base_url = src.split('?').first
    params = extract_params(src)
    
    content_tag(:picture) do
      concat(tag(:source, srcset: webp_url(base_url, params), type: "image/webp"))
      concat(tag(:source, srcset: src, type: "image/jpeg"))
      concat(image_tag(src, alt: alt, loading: loading, class: css_class, width: width, height: height, decoding: "async"))
    end
  end

  # Optimize Unsplash image URL
  def optimized_unsplash(url, width: 800, height: nil, quality: 80, format: 'auto')
    return url unless url.include?('unsplash.com')
    
    params = []
    params << "w=#{width}" if width
    params << "h=#{height}" if height
    params << "q=#{quality}"
    params << "fm=#{format}"
    params << "fit=crop"
    
    base_url = url.split('?').first
    "#{base_url}?#{params.join('&')}"
  end

  private

  def extract_params(url)
    return {} unless url.include?('?')
    
    query = url.split('?').last
    query.split('&').each_with_object({}) do |param, hash|
      key, value = param.split('=')
      hash[key] = value
    end
  end

  def generate_srcset(base_url, params)
    widths = [400, 800, 1200, 1600]
    widths.map do |width|
      new_params = params.merge('w' => width.to_s)
      query = new_params.map { |k, v| "#{k}=#{v}" }.join('&')
      "#{base_url}?#{query} #{width}w"
    end.join(', ')
  end

  def webp_url(base_url, params)
    new_params = params.merge('fm' => 'webp')
    query = new_params.map { |k, v| "#{k}=#{v}" }.join('&')
    "#{base_url}?#{query}"
  end
end

