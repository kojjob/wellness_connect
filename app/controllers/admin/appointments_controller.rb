module Admin
  class AppointmentsController < BaseController
    before_action :set_appointment, only: [ :show ]
    before_action :authorize_appointment

    def index
      @appointments = policy_scope([ :admin, Appointment ]).includes(:patient, :provider, :service).order(start_time: :desc)

      # Filter by status
      if params[:status].present? && Appointment.statuses.keys.include?(params[:status])
        @appointments = @appointments.where(status: params[:status])
      end

      # Filter by date range
      if params[:start_date].present?
        @appointments = @appointments.where("start_time >= ?", Date.parse(params[:start_date]).beginning_of_day)
      end

      if params[:end_date].present?
        @appointments = @appointments.where("start_time <= ?", Date.parse(params[:end_date]).end_of_day)
      end

      # Search by patient or provider name or service
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @appointments = @appointments.joins("JOIN users AS patients ON patients.id = appointments.patient_id")
                                     .joins("JOIN users AS providers ON providers.id = appointments.provider_id")
                                     .joins(:service)
                                     .where(
                                       "patients.first_name ILIKE ? OR patients.last_name ILIKE ? OR providers.first_name ILIKE ? OR providers.last_name ILIKE ? OR services.name ILIKE ?",
                                       search_term, search_term, search_term, search_term, search_term
                                     )
      end

      @appointments = @appointments.page(params[:page]).per(20)
    end

    def show
      # Instance variable set by before_action
      @payment = @appointment.payment
    end

    private

    def set_appointment
      @appointment = Appointment.find(params[:id])
    end

    def authorize_appointment
      if @appointment
        authorize [ :admin, @appointment ]
      else
        authorize [ :admin, Appointment ]
      end
    end
  end
end
