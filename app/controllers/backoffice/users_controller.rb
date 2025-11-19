class Backoffice::UsersController < Backoffice::BaseController
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
    @users = Product.new(users_params)

    if @users.save
      redirect_to backoffice_users_path, notice: "Usuario creado correctamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @users.assign_attributes(users_params)

    if @product.save
      redirect_to backoffice_users_path, notice: "Usuario actualizado"
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
