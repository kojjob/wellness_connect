class ProviderProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_provider_profile, only: [ :show, :edit, :update, :destroy ]

  def index
    @provider_profiles = ProviderProfile.all
    authorize @provider_profiles
  end

  def show
    authorize @provider_profile
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
