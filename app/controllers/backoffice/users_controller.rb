class Backoffice::UsersController < Backoffice::BaseController
  load_and_authorize_resource
  
  # Helper method to get available roles based on current user's role
  helper_method :available_roles

  
	def index
		@q = User.ransack(params[:q])
		@users = @q.result(distinct: true)
									.order(created_at: :desc)
									.page(params[:page])
									.per(2)
	end

  def new
  end

  def create
    @user.assigned_by = current_user
    @user.password = Devise.friendly_token.first(20)
    if @user.save
      UserMailer.welcome_email(@user, @user.password).deliver_now
      redirect_to backoffice_users_path, notice: "Usuario creado correctamente"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
  end

  def edit
  end

  def update
    @user.assigned_by = current_user
    
    if @user.update(user_params)
      redirect_to backoffice_users_path, notice: "Usuario actualizado"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to backoffice_users_path, notice: "Usuario eliminado"
	end

  private

  def user_params
    params.require(:user).permit(:name, :surname, :email, :address, :role)
  end
  
  def available_roles
    User.assignable_roles_for(current_user)
  end

end
