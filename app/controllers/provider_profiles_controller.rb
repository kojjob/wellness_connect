class ProviderProfilesController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_provider_profile, only: [ :show, :edit, :update, :destroy ]

  def index
    @provider_profiles = ProviderProfile.includes(:user, :services, :availabilities).all

    # Search by provider name, specialty, or bio
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @provider_profiles = @provider_profiles.joins(:user)
                                             .where("users.first_name ILIKE ? OR users.last_name ILIKE ? OR provider_profiles.specialty ILIKE ? OR provider_profiles.bio ILIKE ?",
                                                    search_term, search_term, search_term, search_term)
    end

    # Filter by specialty
    if params[:specialty].present?
      @provider_profiles = @provider_profiles.where(specialty: params[:specialty])
    end

    # Filter by price range
    if params[:price_min].present?
      @provider_profiles = @provider_profiles.where("consultation_rate >= ?", params[:price_min])
    end

    if params[:price_max].present?
      @provider_profiles = @provider_profiles.where("consultation_rate <= ?", params[:price_max])
    end

    # Filter by minimum rating
    if params[:min_rating].present?
      min_rating = params[:min_rating].to_f
      @provider_profiles = @provider_profiles.select { |p| p.average_rating >= min_rating }
    end

    # Filter by years of experience
    if params[:min_experience].present?
      @provider_profiles = @provider_profiles.where("years_of_experience >= ?", params[:min_experience])
    end

    # Filter by languages
    if params[:language].present?
      @provider_profiles = @provider_profiles.where("languages ILIKE ?", "%#{params[:language]}%")
    end

    # Filter by session format
    if params[:session_format].present?
      @provider_profiles = @provider_profiles.where("session_formats ILIKE ?", "%#{params[:session_format]}%")
    end

    # Sorting
    case params[:sort]
    when "rating_desc"
      @provider_profiles = @provider_profiles.sort_by { |p| -p.average_rating }
    when "price_asc"
      @provider_profiles = @provider_profiles.order(consultation_rate: :asc)
    when "price_desc"
      @provider_profiles = @provider_profiles.order(consultation_rate: :desc)
    when "experience_desc"
      @provider_profiles = @provider_profiles.order(years_of_experience: :desc)
    when "newest"
      @provider_profiles = @provider_profiles.order(created_at: :desc)
    else
      # Default: highest rated first
      @provider_profiles = @provider_profiles.sort_by { |p| -p.average_rating } if @provider_profiles.is_a?(Array)
    end

    # Convert to array if it's still an ActiveRecord relation and we need array operations
    @provider_profiles = @provider_profiles.to_a if @provider_profiles.is_a?(ActiveRecord::Relation) && params[:min_rating].present?

    # Get unique specialties for filter dropdown
    @specialties = ProviderProfile.distinct.pluck(:specialty).compact.sort

    # Get available languages for filter
    @languages = ProviderProfile.where.not(languages: nil)
                                .pluck(:languages)
                                .flat_map { |l| l.split(",").map(&:strip) }
                                .uniq
                                .sort

    # Get available session formats
    @session_formats = ProviderProfile.where.not(session_formats: nil)
                                      .pluck(:session_formats)
                                      .flat_map { |s| s.split(",").map(&:strip) }
                                      .uniq
                                      .sort

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
