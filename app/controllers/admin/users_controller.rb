# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [ :show, :edit, :update, :destroy, :suspend, :unsuspend, :block, :unblock, :remove_avatar ]

    def index
      authorize User

      # Base query
      @users = policy_scope(User)

      # Search
      if params[:q].present?
        @users = @users.search(params[:q])
      end

      # Filter by role
      if params[:role].present? && User.roles.keys.include?(params[:role])
        @users = @users.where(role: params[:role])
      end

      # Filter by status
      case params[:status]
      when "active"
        @users = @users.active
      when "suspended"
        @users = @users.suspended
      when "blocked"
        @users = @users.blocked
      when "inactive"
        @users = @users.inactive
      end

      # Filter by date range
      if params[:start_date].present?
        @users = @users.where("created_at >= ?", Date.parse(params[:start_date]).beginning_of_day)
      end

      if params[:end_date].present?
        @users = @users.where("created_at <= ?", Date.parse(params[:end_date]).end_of_day)
      end

      # Sorting
      sort_column = params[:sort] || "created_at"
      sort_direction = params[:direction] || "desc"

      # Validate sort column
      allowed_columns = %w[first_name last_name email role created_at]
      sort_column = "created_at" unless allowed_columns.include?(sort_column)
      sort_direction = "desc" unless %w[asc desc].include?(sort_direction)

      @users = @users.order("#{sort_column} #{sort_direction}")

      # Statistics
      @total_users = User.count
      @active_users = User.active.count
      @providers_count = User.where(role: "provider").count
      @patients_count = User.where(role: "patient").count
      @recent_signups = User.where("created_at >= ?", 7.days.ago).count

      # Pagination
      @per_page = params[:per_page]&.to_i || 20
      @per_page = 20 unless [20, 50, 100].include?(@per_page)
      @users = @users.page(params[:page]).per(@per_page)
    end

    def show
      authorize @user
    end

    def new
      @user = User.new
      authorize @user
    end

    def create
      @user = User.new(user_params)
      authorize @user

      if @user.save
        redirect_to admin_user_path(@user), notice: "User successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @user
    end

    def update
      authorize @user

      if @user.update(user_params)
        respond_to do |format|
          format.html { redirect_to admin_user_path(@user), notice: "User successfully updated." }
          format.json { render json: { success: true, message: "User successfully updated." } }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: { success: false, errors: @user.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      authorize @user
      @user.destroy!
      redirect_to admin_users_path, notice: "User successfully deleted."
    end

    def suspend
      authorize @user
      @user.suspend!(params[:reason])
      redirect_to admin_user_path(@user), notice: "User successfully suspended."
    end

    def unsuspend
      authorize @user
      @user.unsuspend!
      redirect_to admin_user_path(@user), notice: "User successfully unsuspended."
    end

    def block
      authorize @user
      @user.block!(params[:reason])
      redirect_to admin_user_path(@user), notice: "User successfully blocked."
    end

    def unblock
      authorize @user
      @user.unblock!
      redirect_to admin_user_path(@user), notice: "User successfully unblocked."
    end

    def remove_avatar
      authorize @user

      if @user.avatar.attached?
        @user.avatar.purge
        render json: { success: true, message: "Avatar removed successfully." }
      else
        render json: { success: false, message: "No avatar to remove." }, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :role, :avatar)
    end
  end
end
