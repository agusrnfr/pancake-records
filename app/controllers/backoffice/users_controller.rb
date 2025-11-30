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
    # Verificar si hay un usuario eliminado con el mismo email
    existing_removed_user = User.removed.find_by(email: user_params[:email])
    
    if existing_removed_user && params[:confirm_restore] != 'true'
      # Usuario eliminado existe, mostrar confirmación
      @user = User.new(user_params)
      @existing_user = existing_removed_user
      @show_restore_confirmation = true
      render :new, status: :unprocessable_entity
      return
    end

    if existing_removed_user && params[:confirm_restore] == 'true'
      # Restaurar usuario existente sin actualizar sus valores
      existing_removed_user.restore!
      redirect_to backoffice_users_path, notice: "Usuario restaurado correctamente"
      return
    end

    # Crear nuevo usuario normalmente
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
    if @user.removed?
      redirect_to backoffice_users_path, alert: "El usuario ya está eliminado"
    else
      @user.remove!
      redirect_to backoffice_users_path, notice: "Usuario eliminado correctamente"
    end
	end

  def restore
    if @user.removed?
      @user.restore!
      redirect_to backoffice_users_path, notice: "Usuario restaurado correctamente"
    else
      redirect_to backoffice_users_path, alert: "El usuario no está eliminado"
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :surname, :email, :address, :role)
  end
  
  def available_roles
    User.assignable_roles_for(current_user)
  end

end
