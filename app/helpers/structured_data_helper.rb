module StructuredDataHelper
  def organization_schema
    {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": "WellnessConnect",
      "url": root_url,
      "logo": "#{root_url}logo.png",
      "description": "Connect with qualified service providers for virtual consultations and professional services.",
      "contactPoint": {
        "@type": "ContactPoint",
        "telephone": "+1-555-WELLNESS",
        "contactType": "Customer Service",
        "areaServed": "US",
        "availableLanguage": ["English"]
      },
      "sameAs": [
        "https://facebook.com/wellnessconnect",
        "https://twitter.com/wellnessconnect",
        "https://linkedin.com/company/wellnessconnect"
      ]
    }.to_json.html_safe
  end

  def website_schema
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "name": "WellnessConnect",
      "url": root_url,
      "potentialAction": {
        "@type": "SearchAction",
        "target": {
          "@type": "EntryPoint",
          "urlTemplate": "#{root_url}providers?q={search_term_string}"
        },
        "query-input": "required name=search_term_string"
      }
    }.to_json.html_safe
  end

  def medical_business_schema
    {
      "@context": "https://schema.org",
      "@type": "MedicalBusiness",
      "name": "WellnessConnect",
      "description": "Professional wellness and consulting services marketplace",
      "url": root_url,
      "aggregateRating": {
        "@type": "AggregateRating",
        "ratingValue": "4.9",
        "reviewCount": "50000",
        "bestRating": "5",
        "worstRating": "1"
      },
      "priceRange": "$$"
    }.to_json.html_safe
  end

  def faq_schema(faqs)
    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": faqs.map do |faq|
        {
          "@type": "Question",
          "name": faq[:question],
          "acceptedAnswer": {
            "@type": "Answer",
            "text": faq[:answer]
          }
        }
      end
    }.to_json.html_safe
  end

  def service_schema(service)
    {
      "@context": "https://schema.org",
      "@type": "Service",
      "serviceType": service[:name],
      "provider": {
        "@type": "Organization",
        "name": "WellnessConnect"
      },
      "areaServed": {
        "@type": "Country",
        "name": "United States"
      },
      "description": service[:description],
      "offers": {
        "@type": "Offer",
        "availability": "https://schema.org/InStock"
      }
    }.to_json.html_safe
  end

  def breadcrumb_schema(items)
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": items.map.with_index do |item, index|
        {
          "@type": "ListItem",
          "position": index + 1,
          "name": item[:name],
          "item": item[:url]
        }
      end
    }.to_json.html_safe
  end
end

