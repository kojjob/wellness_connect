# frozen_string_literal: true

# Test controller for flash message system testing
# Only available in test environment
class TestFlashController < ApplicationController
  skip_before_action :verify_authenticity_token, if: -> { Rails.env.test? }
  skip_before_action :authenticate_user!, if: -> { Rails.env.test? }

  def success
    flash.now[:success] = "Success message"
    render_flash_test
  end

  def error
    flash.now[:error] = "Error message"
    render_flash_test
  end

  def warning
    flash.now[:warning] = "Warning message"
    render_flash_test
  end

  def info
    flash.now[:info] = "Info message"
    render_flash_test
  end

  def notice
    flash.now[:notice] = "Notice message"
    render_flash_test
  end

  def multiple
    flash.now[:success] = "First message"
    flash.now[:error] = "Second message"
    flash.now[:warning] = "Third message"
    render_flash_test
  end

  def turbo_stream_flash
    # For system tests, render HTML with initial flash content
    flash.now[:success] = "Turbo Stream message"
    render_flash_test
  end

  private

  def render_flash_test
    render inline: <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>Test Flash</title>
          <meta name="viewport" content="width=device-width,initial-scale=1">
          <%= csrf_meta_tags %>
          <%= csp_meta_tag %>
          <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
          <%= javascript_importmap_tags %>
        </head>
        <body>
          <%= render "shared/flash" %>
          <p>Flash message displayed</p>
        </body>
      </html>
    HTML
  end
end
