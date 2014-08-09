class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def update
    if current_user.update_attributes(user_params)
      flash[:notice] = "User information updated"
      redirect_to edit_user_registration_path(current_user)
    else
      render "devise/registrations/edit"
    end
  end

  def finish_signup
    if request.patch? && params[:user] 
      if current_user.update(user_params)
        current_user.skip_reconfirmation!
        current_user.confirm!
        sign_in(current_user, :bypass => true)
        redirect_to todos_path, notice: 'Your profile was successfully updated.'
      else
        @show_errors = true
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    accessible = [ :name, :email ] 
    accessible << [ :password, :password_confirmation ] unless params[:user][:password].blank?
    params.require(:user).permit(:accessible, :email)
  end

  def show
    @completed = current_user.completed
  end



end