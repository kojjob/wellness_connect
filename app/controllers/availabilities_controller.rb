class AvailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_provider_profile
  before_action :set_availability, only: [ :show, :edit, :update, :destroy ]

  def index
    @availabilities = @provider_profile.availabilities.order(start_time: :asc)
  end

  def show
  end

  def new
    @availability = @provider_profile.availabilities.build
    authorize @availability
  end

  def create
    @availability = @provider_profile.availabilities.build(availability_params)
    authorize @availability

    if @availability.save
      redirect_to provider_profile_availabilities_url(@provider_profile), notice: "Availability was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @availability
  end

  def update
    authorize @availability

    if @availability.update(availability_params)
      redirect_to provider_profile_availabilities_url(@provider_profile), notice: "Availability was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @availability
    @availability.destroy!
    redirect_to provider_profile_availabilities_url(@provider_profile), notice: "Availability was successfully deleted."
  end

  private

  def set_provider_profile
    @provider_profile = ProviderProfile.find(params[:provider_profile_id])
  end

  def set_availability
    @availability = @provider_profile.availabilities.find(params[:id])
  end

  def availability_params
    params.require(:availability).permit(:start_time, :end_time, :is_booked)
  end
end
