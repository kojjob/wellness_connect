class LeadsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    @lead = Lead.new(lead_params)

    if @lead.save
      # Send welcome email (optional - implement later)
      # LeadMailer.welcome_email(@lead).deliver_later

      respond_to do |format|
        format.html { redirect_to root_path, notice: "Success! Check your email for your 10% discount code." }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "lead-form",
            partial: "leads/success"
          )
        }
        format.json { render json: { success: true, message: "Thank you! Check your email." }, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: @lead.errors.full_messages.join(", ") }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "lead-form",
            partial: "leads/form",
            locals: { lead: @lead }
          )
        }
        format.json { render json: { success: false, errors: @lead.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def lead_params
    params.require(:lead).permit(:email, :source, :utm_campaign, :utm_source, :utm_medium)
  end
end
