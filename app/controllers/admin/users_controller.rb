# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [ :show, :edit, :update, :destroy, :suspend, :unsuspend, :block, :unblock, :remove_avatar ]

    def index
      authorize [ :admin, User ]

      # Base query
      @users = policy_scope([ :admin, User ])

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
      @per_page = 20 unless [ 20, 50, 100 ].include?(@per_page)
      @users = @users.page(params[:page]).per(@per_page)
    end

    def show
      authorize [ :admin, @user ]
    end

    def new
      @user = User.new
      authorize [ :admin, @user ]
    end

    def create
      @user = User.new(user_params)
      authorize [ :admin, @user ]

      if @user.save
        # Automatically create role-specific profiles
        create_role_profile(@user)

        redirect_to admin_user_path(@user), notice: "User successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize [ :admin, @user ]
    end

    def update
      authorize [ :admin, @user ]

      # Handle avatar removal if requested
      if params[:user][:remove_avatar] == "1"
        @user.avatar.purge if @user.avatar.attached?
      end

      # Track if role is changing
      role_changed = @user.role != user_params[:role]

      if @user.update(user_params)
        # Create role-specific profile if role changed
        create_role_profile(@user) if role_changed

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
      authorize [ :admin, @user ]
      @user.destroy!
      redirect_to admin_users_path, notice: "User successfully deleted."
    end

    def suspend
      authorize [ :admin, @user ]
      @user.suspend!(params[:reason])
      redirect_to admin_user_path(@user), notice: "User successfully suspended."
    end

    def unsuspend
      authorize [ :admin, @user ]
      @user.unsuspend!
      redirect_to admin_user_path(@user), notice: "User successfully unsuspended."
    end

    def block
      authorize [ :admin, @user ]
      @user.block!(params[:reason])
      redirect_to admin_user_path(@user), notice: "User successfully blocked."
    end

    def unblock
      authorize [ :admin, @user ]
      @user.unblock!
      redirect_to admin_user_path(@user), notice: "User successfully unblocked."
    end

    def remove_avatar
      authorize [ :admin, @user ]

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

    # Create role-specific profile for provider or patient users
    def create_role_profile(user)
      case user.role
      when "provider"
        # Create provider profile with default values
        # Full profile details can be added later through the provider profile interface
        user.create_provider_profile!(
          specialty: "To be determined",
          bio: "Profile to be completed",
          credentials: "To be added",
          consultation_rate: 0.0
        ) unless user.provider_profile.present?
      when "patient"
        # Create patient profile
        # Additional health information can be added later
        user.create_patient_profile! unless user.patient_profile.present?
      end
    rescue ActiveRecord::RecordInvalid => e
      # Log the error but don't fail the user creation
      Rails.logger.error("Failed to create profile for user #{user.id}: #{e.message}")
    end
  end
end
