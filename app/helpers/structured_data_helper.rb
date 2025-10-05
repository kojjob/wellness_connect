module StructuredDataHelper
  def organization_schema
    {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": "WellnessConnect",
      "url": root_url,
      "logo": "#{root_url}logo.png",
      "description": "Connect with certified wellness providers for virtual consultations. Get personalized care from the comfort of your home.",
      "foundingDate": "2024",
      "contactPoint": {
        "@type": "ContactPoint",
        "telephone": "+1-555-WELLNESS",
        "contactType": "Customer Service",
        "email": "hello@wellnessconnect.com",
        "availableLanguage": ["English"]
      },
      "sameAs": [
        "https://facebook.com/wellnessconnect",
        "https://twitter.com/wellnessconnect",
        "https://linkedin.com/company/wellnessconnect",
        "https://instagram.com/wellnessconnect"
      ]
    }.to_json.html_safe
  end

  def medical_business_schema
    {
      "@context": "https://schema.org",
      "@type": "MedicalBusiness",
      "name": "WellnessConnect",
      "description": "Virtual wellness and healthcare platform connecting patients with certified providers",
      "url": root_url,
      "image": "#{root_url}og-image.jpg",
      "telephone": "+1-555-WELLNESS",
      "email": "hello@wellnessconnect.com",
      "address": {
        "@type": "PostalAddress",
        "addressCountry": "US",
        "addressRegion": "Nationwide"
      },
      "aggregateRating": {
        "@type": "AggregateRating",
        "ratingValue": "4.9",
        "reviewCount": "10000",
        "bestRating": "5",
        "worstRating": "1"
      },
      "priceRange": "$$",
      "paymentAccepted": "Credit Card, Debit Card, HSA, FSA",
      "openingHours": "Mo-Su 00:00-23:59",
      "hasOfferCatalog": {
        "@type": "OfferCatalog",
        "name": "Wellness Services",
        "itemListElement": [
          {
            "@type": "Offer",
            "itemOffered": {
              "@type": "Service",
              "name": "Mental Health Therapy",
              "description": "Licensed therapists and counselors"
            }
          },
          {
            "@type": "Offer",
            "itemOffered": {
              "@type": "Service",
              "name": "Nutrition Counseling",
              "description": "Certified nutritionists and dietitians"
            }
          },
          {
            "@type": "Offer",
            "itemOffered": {
              "@type": "Service",
              "name": "Fitness Coaching",
              "description": "Personal trainers and fitness experts"
            }
          },
          {
            "@type": "Offer",
            "itemOffered": {
              "@type": "Service",
              "name": "Alternative Medicine",
              "description": "Holistic wellness practitioners"
            }
          }
        ]
      }
    }.to_json.html_safe
  end

  def faq_schema
    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": [
        {
          "@type": "Question",
          "name": "How do I book a session?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Browse our provider directory, select a provider that matches your needs, view their available time slots, and book directly through our platform. You'll receive instant confirmation and calendar invites for your session."
          }
        },
        {
          "@type": "Question",
          "name": "Are all providers verified and licensed?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Yes! All wellness providers on our platform undergo a thorough verification process. We verify credentials, licenses, certifications, and professional background to ensure you receive care from qualified professionals."
          }
        },
        {
          "@type": "Question",
          "name": "How do virtual sessions work?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Virtual sessions are conducted via secure video conferencing. You'll receive a unique session link before your appointment. Simply click the link at your scheduled time to join from any device with a camera and internet connection."
          }
        },
        {
          "@type": "Question",
          "name": "What is your cancellation policy?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "You can cancel or reschedule appointments up to 24 hours before your scheduled time for a full refund. Cancellations made within 24 hours may be subject to a cancellation fee, depending on the provider's policy."
          }
        },
        {
          "@type": "Question",
          "name": "Is my information secure?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Absolutely. We use bank-level encryption to protect your data and are fully HIPAA compliant. Your personal health information is never shared without your explicit consent, and all sessions are conducted through secure, encrypted connections."
          }
        },
        {
          "@type": "Question",
          "name": "Do you accept insurance?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Payment is processed directly through our platform. While we don't bill insurance directly, we provide detailed receipts that you can submit to your insurance provider for potential reimbursement. Check with your provider about their telehealth coverage."
          }
        }
      ]
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

  def service_schema(name:, description:, price_range:)
    {
      "@context": "https://schema.org",
      "@type": "Service",
      "serviceType": name,
      "description": description,
      "provider": {
        "@type": "Organization",
        "name": "WellnessConnect"
      },
      "areaServed": {
        "@type": "Country",
        "name": "United States"
      },
      "availableChannel": {
        "@type": "ServiceChannel",
        "serviceUrl": root_url,
        "serviceType": "Online"
      },
      "offers": {
        "@type": "AggregateOffer",
        "priceCurrency": "USD",
        "priceRange": price_range,
        "availability": "https://schema.org/InStock"
      }
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
end

