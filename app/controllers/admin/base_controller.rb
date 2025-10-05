# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :require_admin!

    private

    def require_admin!
      unless current_user&.admin? || current_user&.super_admin?
        flash[:alert] = "You are not authorized to perform this action."
        redirect_to root_path
      end
    end
  end
end
