class ProviderProfilesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_provider_profile, only: [ :show, :edit, :update, :destroy ]

  def index
    @provider_profiles = ProviderProfile.includes(:user, :services, :availabilities).all

    # Filter by specialty if provided
    if params[:specialty].present?
      @provider_profiles = @provider_profiles.where(specialty: params[:specialty])
    end

    # Search by provider name if provided
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @provider_profiles = @provider_profiles.joins(:user)
                                             .where("users.first_name ILIKE ? OR users.last_name ILIKE ?",
                                                    search_term, search_term)
    end

    # Don't require authorization for public browsing
    authorize @provider_profiles if user_signed_in?
  end

  def show
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
    params.require(:provider_profile).permit(:specialty, :bio, :credentials, :consultation_rate)
  end
end
