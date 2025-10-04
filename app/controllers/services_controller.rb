class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_provider_profile
  before_action :set_service, only: [ :show, :edit, :update, :destroy ]

  def index
    @services = @provider_profile.services
    authorize @services
  end

  def show
    authorize @service
  end

  def new
    @service = @provider_profile.services.build
    authorize @service
  end

  def create
    @service = @provider_profile.services.build(service_params)
    authorize @service

    if @service.save
      redirect_to provider_profile_service_path(@provider_profile, @service), notice: "Service was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @service
  end

  def update
    authorize @service

    if @service.update(service_params)
      redirect_to provider_profile_service_path(@provider_profile, @service), notice: "Service was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @service
    @service.destroy!

    redirect_to provider_profile_services_path(@provider_profile), status: :see_other, notice: "Service was successfully destroyed."
  end

  private

  def set_provider_profile
    @provider_profile = ProviderProfile.find(params[:provider_profile_id])
  end

  def set_service
    @service = @provider_profile.services.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:name, :description, :duration_minutes, :price, :is_active)
  end
end
