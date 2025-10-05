module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :edit, :update ]
    before_action :authorize_user

    def index
      @users = policy_scope(User).order(created_at: :desc)

      # Filter by role if specified
      if params[:role].present? && User.roles.keys.include?(params[:role])
        @users = @users.where(role: params[:role])
      end

      # Search by name or email
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @users = @users.where(
          "first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
          search_term, search_term, search_term
        )
      end

      @users = @users.page(params[:page]).per(20)
    end

    def show
      # Instance variable set by before_action
    end

    def edit
      # Instance variable set by before_action
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "User successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def authorize_user
      if @user
        authorize [ :admin, @user ]
      else
        authorize [ :admin, User ]
      end
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :role)
    end
  end
end
