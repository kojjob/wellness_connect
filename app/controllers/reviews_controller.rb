class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_provider_profile
  before_action :set_review, only: [ :edit, :update, :destroy ]

  def new
    @review = @provider_profile.reviews.build
    authorize @review
  end

  def create
    @review = @provider_profile.reviews.build(review_params)
    @review.reviewer = current_user
    authorize @review

    if @review.save
      redirect_to @provider_profile, notice: "Review was successfully created. Thank you for your feedback!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @review
  end

  def update
    authorize @review

    if @review.update(review_params)
      redirect_to @provider_profile, notice: "Review was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @review
    @review.destroy!

    redirect_to @provider_profile, notice: "Review was successfully deleted."
  end

  private

  def set_provider_profile
    @provider_profile = ProviderProfile.find(params[:provider_profile_id])
  end

  def set_review
    @review = @provider_profile.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :comment)
  end
end
