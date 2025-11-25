class Backoffice::PasswordsController < ApplicationController
  before_action :authenticate_user!
  layout "backoffice"
  before_action :set_user

  def edit
  end

  def update
    if current_user.update_with_password(password_params)
      bypass_sign_in(current_user)
      redirect_to backoffice_root_path, notice: "Contraseña actualizada"
    else
      render :edit
    end
  end

  private
  def password_params
    params.require(:user).permit(
      :current_password,
      :password,
      :password_confirmation
    )
  end

  def set_user
    @user = User.find(params[:user_id])
  end

end