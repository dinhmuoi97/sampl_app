class UsersController < ApplicationController
  before_action :load_user, only: %i(show edit update destroy, correct_user)
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: %i(destroy)

  def index
    @users = User.page(params[:page]).per Settings.pages_limit
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      log_in @user
      flash[:success] = t "users_controller.wl"
      redirect_to @user
    else
      flash[:danger] = t "users_controller.fails"
      render :new
    end
  end

  def show
    @user = User.find_by id: params[:id]

    return if @user.present?
    flash[:error] = t ".not"
    redirect_to :signup_path
  end

  def edit
  end

  def update
    @user = User.find_by id: params[:id]

    if @user.update_attributes user_params
      flash[:success] = t ".pro_up"
      redirect_to @user
    else
      flash[:danger] = t ".noww"
      render :edit
    end
  end

  def destroy
    @user.destroy ? flash[:success] = t(".userup") : flash[:danger] = t(".xoa")
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t ".plog"
    redirect_to login_url
  end

  def correct_user
    @user = User.find_by id: params[:id]
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def load_user
    return if @user = User.find_by(id: params[:id])
    flash[:ranger] = t ".not_found"
  end
end
