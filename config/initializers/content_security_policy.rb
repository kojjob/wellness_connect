# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, :blob
    policy.object_src  :none
    policy.script_src  :self, :https, :unsafe_inline  # unsafe_inline needed for Stimulus/Turbo
    policy.style_src   :self, :https, :unsafe_inline  # unsafe_inline needed for Tailwind
    policy.connect_src :self, :https, "wss:", "https://api.stripe.com"
    policy.frame_src   :self, "https://js.stripe.com", "https://hooks.stripe.com"
    policy.child_src   :blob

    # Specify URI for violation reports (uncomment in production to monitor violations)
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Report violations without enforcing the policy (set to true initially to monitor)
  # Set to false in production after confirming no legitimate violations
  config.content_security_policy_report_only = Rails.env.development?
end
