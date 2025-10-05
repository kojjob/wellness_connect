class ProviderProfilesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_provider_profile, only: [ :show, :edit, :update, :destroy ]

  def index
    # Cache key includes filter parameters to cache different search results separately
    cache_key = [ "provider_profiles_index", params[:specialty], params[:search] ].compact.join("/")

    @provider_profiles = Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
      profiles = ProviderProfile.includes(:user, :services, :availabilities).all

      # Filter by specialty if provided
      if params[:specialty].present?
        profiles = profiles.where(specialty: params[:specialty])
      end

      # Search by provider name if provided
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        profiles = profiles.joins(:user)
                          .where("users.first_name ILIKE ? OR users.last_name ILIKE ?",
                                 search_term, search_term)
      end

      profiles.to_a # Force query execution and cache the result array
    end

    # Don't require authorization for public browsing
    authorize @provider_profiles if user_signed_in?
  end

  def show
    # Cache provider's services and availabilities separately since they change at different rates
    @services = Rails.cache.fetch([ "provider_services", @provider_profile ], expires_in: 1.hour) do
      @provider_profile.services.order(created_at: :desc).to_a
    end

    @availabilities = Rails.cache.fetch([ "provider_availabilities", @provider_profile, Date.current ], expires_in: 5.minutes) do
      @provider_profile.availabilities
                       .where("start_time >= ?", Time.current)
                       .where(is_booked: false)
                       .order(start_time: :asc)
                       .limit(20)
                       .to_a
    end

    # Don't require authorization for public viewing
    authorize @provider_profile if user_signed_in?
  end

  def new
    @provider_profile = ProviderProfile.new
    authorize @provider_profile
  end

  def create
    @provider_profile = current_user.build_provider_profile(provider_profile_params)
    authorize @provider_profile

    if @provider_profile.save
      redirect_to @provider_profile, notice: "Provider profile was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @provider_profile
  end

  def update
    authorize @provider_profile

    if @provider_profile.update(provider_profile_params)
      redirect_to @provider_profile, notice: "Provider profile was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @provider_profile
    @provider_profile.destroy!

    redirect_to provider_profiles_url, status: :see_other, notice: "Provider profile was successfully destroyed."
  end

  private

  def set_provider_profile
    @provider_profile = ProviderProfile.find(params[:id])
  end

  def provider_profile_params
    params.require(:provider_profile).permit(
      :specialty, :bio, :credentials, :consultation_rate,
      :years_of_experience, :education, :certifications, :languages,
      :phone, :office_address, :website,
      :linkedin_url, :twitter_url, :facebook_url, :instagram_url,
      :avatar,
      gallery_images: [],
      gallery_videos: [],
      gallery_audio: [],
      documents: []
    )
  end
end
