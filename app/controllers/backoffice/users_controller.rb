class Backoffice::UsersController < Backoffice::BaseController
  load_and_authorize_resource
  
  # Helper method to get available roles based on current user's role
  helper_method :available_roles

  
	def index
		@q = User.not_removed.ransack(params[:q])
		@users = @q.result(distinct: true)
									.order(created_at: :desc)
									.page(params[:page])
									.per(8)
	end

  def new
  end

  def create
    existing_removed_user = User.removed.find_by(email: user_params[:email])
    
    return handle_restore_confirmation(existing_removed_user) if existing_removed_user && params[:confirm_restore] != 'true'
    return restore_existing_user(existing_removed_user) if existing_removed_user && params[:confirm_restore] == 'true'
    
    @user.assigned_by = current_user
    temporary_password = Devise.friendly_token.first(20)
    @user.password = temporary_password
    
    if @user.save
      UserMailer.welcome_email(@user, temporary_password).deliver_now
      redirect_to backoffice_users_path, notice: "Usuario creado correctamente"
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def show
  end

  def edit
    @user = User.find(params[:id])
    return redirect_to backoffice_users_path, alert: "Usá tu perfil para editar tu propia cuenta." if @user == current_user
    return redirect_to backoffice_users_path, alert: "El usuario está eliminado" if @user.removed?
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
    return redirect_to backoffice_users_path, alert: "El usuario ya está eliminado" if @user.removed?
    
    @user.remove!
    redirect_to backoffice_users_path, notice: "Usuario eliminado correctamente"
	end

  def restore
    return redirect_to backoffice_users_path, alert: "El usuario no está eliminado" unless @user.removed?
    
    restore_existing_user(@user)
  end

  private

  def user_params
    params.require(:user).permit(:name, :surname, :email, :address, :role)
  end
  
  def available_roles
    User.assignable_roles_for(current_user)
  end
  
  def handle_restore_confirmation(existing_user)
    @user = User.new(user_params)
    @existing_user = existing_user
    @show_restore_confirmation = true
    render :new, status: :unprocessable_entity
  end
  
  def restore_existing_user(user)
    temporary_password = Devise.friendly_token.first(20)
    user.restore!
    user.password = temporary_password
    user.save!
    UserMailer.welcome_back_email(user, temporary_password).deliver_now
    redirect_to backoffice_users_path, notice: "Usuario restaurado correctamente"
  end

end
