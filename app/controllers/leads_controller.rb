class LeadsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :authenticate_user!, only: [:create]

  def create
    @lead = Lead.new(lead_params)

    if @lead.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "lead-form-wrapper",
            partial: "leads/success",
            locals: { lead: @lead }
          )
        end
        format.json do
          render json: {
            message: "Lead created successfully",
            email: @lead.email
          }, status: :created
        end
        format.html do
          render partial: "leads/success", locals: { lead: @lead }
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "lead-form-wrapper",
            partial: "leads/form",
            locals: { lead: @lead }
          ), status: :unprocessable_entity
        end
        format.json do
          render json: { errors: @lead.errors.full_messages }, status: :unprocessable_entity
        end
        format.html do
          render partial: "leads/form", locals: { lead: @lead }, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def lead_params
    params.require(:lead).permit(:email, :source, :utm_campaign, :utm_source, :utm_medium, :subscribed)
  end
end
