class PagesController < ApplicationController
  # Allow public access to static pages
  skip_before_action :authenticate_user!

  def become_provider
  end

  def about
  end
end
