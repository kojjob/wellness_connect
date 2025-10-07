module Admin
  class ProviderProfilesController < BaseController
    before_action :set_provider_profile, only: [ :show, :edit, :update, :destroy ]
    before_action :authorize_provider_profile

    def index
      @provider_profiles = policy_scope([ :admin, ProviderProfile ]).includes(:user, :services, :reviews).order(created_at: :desc)

      # Search by provider name, specialty, or credentials
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @provider_profiles = @provider_profiles.joins(:user).where(
          "users.first_name ILIKE ? OR users.last_name ILIKE ? OR provider_profiles.specialty ILIKE ? OR provider_profiles.credentials ILIKE ?",
          search_term, search_term, search_term, search_term
        )
      end

      # Filter by specialty
      if params[:specialty].present?
        @provider_profiles = @provider_profiles.where("specialty ILIKE ?", "%#{params[:specialty]}%")
      end

      @provider_profiles = @provider_profiles.page(params[:page]).per(20)
    end

    def show
      # Instance variable set by before_action
      @services = @provider_profile.services.order(created_at: :desc)
      @availabilities = @provider_profile.availabilities.where("start_time >= ?", Time.current).order(start_time: :asc).limit(10)
      @reviews = @provider_profile.reviews.includes(:reviewer).order(created_at: :desc).limit(10)
      @appointments = @provider_profile.user.appointments_as_provider.includes(:patient, :service).order(start_time: :desc).limit(10)
    end

    def new
      @provider_profile = ProviderProfile.new
      # Get all users with provider role who don't have a profile yet
      @available_providers = User.where(role: :provider).left_joins(:provider_profile).where(provider_profiles: { id: nil })
    end

    def create
      @provider_profile = ProviderProfile.new(provider_profile_params)

      if @provider_profile.save
        redirect_to admin_provider_profile_path(@provider_profile), notice: "Provider profile successfully created."
      else
        @available_providers = User.where(role: :provider).left_joins(:provider_profile).where(provider_profiles: { id: nil })
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      # Instance variable set by before_action
    end

    def update
      if @provider_profile.update(provider_profile_params)
        redirect_to admin_provider_profile_path(@provider_profile), notice: "Provider profile successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @provider_profile.destroy!
      redirect_to admin_provider_profiles_path, notice: "Provider profile successfully deleted."
    end

    private

    def set_provider_profile
      @provider_profile = ProviderProfile.find(params[:id])
    end

    def authorize_provider_profile
      if @provider_profile
        authorize [ :admin, @provider_profile ]
      else
        authorize [ :admin, ProviderProfile ]
      end
    end

    def provider_profile_params
      params.require(:provider_profile).permit(
        :user_id, :specialty, :bio, :credentials, :consultation_rate,
        :years_of_experience, :education, :certifications, :languages,
        :phone, :office_address, :website,
        :linkedin_url, :twitter_url, :facebook_url, :instagram_url,
        :philosophy,
        :avatar,
        areas_of_expertise: [],
        treatment_modalities: [],
        session_formats: [],
        industries_served: [],
        gallery_images: [],
        gallery_videos: [],
        gallery_audio: [],
        documents: []
      )
    end
  end
end
