class Backoffice::UsersController < Backoffice::BaseController
  load_and_authorize_resource

  def index
    per_page = 10
    page = params[:page].to_i
    page = 1 if page < 1

    scope = User.filtered(params).order(created_at: :desc)
    @total_count = scope.count
    @total_pages = (@total_count.to_f / per_page).ceil
    page = @total_pages if @total_pages > 0 && page > @total_pages

    @users = scope.offset((page - 1) * per_page).limit(per_page)
    @current_page = page
  end

  def new
  end

  def create
    temporary_password = Devise.friendly_token[0, 20]
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
  end

  def update
    @user.assign_attributes(user_params)

    if @user.save
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

end
