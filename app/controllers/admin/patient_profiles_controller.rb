module Admin
  class PatientProfilesController < BaseController
    before_action :set_patient_profile, only: [ :show, :edit, :update, :destroy ]
    before_action :authorize_patient_profile

    def index
      @patient_profiles = policy_scope([ :admin, PatientProfile ]).includes(:user).order(created_at: :desc)

      # Search by patient name
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @patient_profiles = @patient_profiles.joins(:user).where(
          "users.first_name ILIKE ? OR users.last_name ILIKE ?",
          search_term, search_term
        )
      end

      @patient_profiles = @patient_profiles.page(params[:page]).per(20)
    end

    def show
      # Instance variable set by before_action
      @appointments = @patient_profile.user.appointments_as_patient.includes(:provider, :service).order(start_time: :desc).limit(10)
    end

    def new
      @patient_profile = PatientProfile.new
      # Get all users with patient role who don't have a profile yet
      @available_patients = User.where(role: :patient).left_joins(:patient_profile).where(patient_profiles: { id: nil })
    end

    def create
      @patient_profile = PatientProfile.new(patient_profile_params)

      if @patient_profile.save
        redirect_to admin_patient_profile_path(@patient_profile), notice: "Patient profile successfully created."
      else
        @available_patients = User.where(role: :patient).left_joins(:patient_profile).where(patient_profiles: { id: nil })
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      # Instance variable set by before_action
    end

    def update
      if @patient_profile.update(patient_profile_params)
        redirect_to admin_patient_profile_path(@patient_profile), notice: "Patient profile successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @patient_profile.destroy!
      redirect_to admin_patient_profiles_path, notice: "Patient profile successfully deleted."
    end

    private

    def set_patient_profile
      @patient_profile = PatientProfile.find(params[:id])
    end

    def authorize_patient_profile
      if @patient_profile
        authorize [ :admin, @patient_profile ]
      else
        authorize [ :admin, PatientProfile ]
      end
    end

    def patient_profile_params
      params.require(:patient_profile).permit(
        :user_id, :date_of_birth, :health_goals, :medical_history_summary
      )
    end
  end
end
