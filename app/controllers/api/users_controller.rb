class Api::UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])

    if current_user == @user
      @photos = current_user.photos.page(params[:page]).per(@per)
    elsif current_user && current_user.following?(@user)
      @photos = @user.follower_photos.page(params[:page]).per(@per)
    else
      @photos = @user.public_photos.page(params[:page]).per(@per)
    end

    @page_number = params[:page].to_i
    @total_pages = @photos.total_pages
  end

  def create
    @user = User.new(user_params)

    if @user.save
      log_in! @user
      render :show
    else
      render json: @user.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end
end
