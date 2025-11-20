class Backoffice::UsersController < Backoffice::BaseController
    load_and_authorize_resource
    def index
    per_page = 10
    page = params[:page].to_i
    page = 1 if page < 1

    scope = Product.filtered(params).order(created_at: :desc)
    @total_count = scope.count
    @total_pages = (@total_count.to_f / per_page).ceil
    page = @total_pages if @total_pages > 0 && page > @total_pages

    @users = scope.offset((page - 1) * per_page).limit(per_page)
    @current_page = page
  end

  def show
  end

  def new
    @users = Product.new
  end

  def create
    @user = User.new(user_params)
    @user.password = Devise.friendly_token[0, 20] # si vos le asignás password temporal
    @user.save!
  end

  def edit
  end

  def update
    @user.assign_attributes(user_params)

    if @user.save
      redirect_to backoffice_users_path, notice: "Usuario actualizado"
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :surname, :email, :address, :role)
  end

end
