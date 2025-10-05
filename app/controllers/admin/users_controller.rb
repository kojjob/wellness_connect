# frozen_string_literal: true

module Admin
  class UsersController < Admin::BaseController
    before_action :set_user, only: [ :show, :edit, :update, :destroy, :suspend, :unsuspend, :block, :unblock ]

    def index
      @users = policy_scope(User).search(params[:q]).order(created_at: :desc)
      authorize User
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
        redirect_to admin_user_path(@user), notice: "User successfully updated."
      else
        render :edit, status: :unprocessable_entity
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

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :role)
    end
  end
end
