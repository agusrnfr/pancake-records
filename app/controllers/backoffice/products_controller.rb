class Backoffice::ProductsController < ApplicationController
	include ActionView::RecordIdentifier
  before_action :set_product, only: [:show, :edit, :update, :increment_stock, :decrement_stock, :soft_delete, :restore]
  layout "backoffice"
	load_and_authorize_resource


	def index
		@q = Product.ransack(params[:q])
		@products = @q.result(distinct: true)
									.order(created_at: :desc)
									.page(params[:page])
									.per(8)
	end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params.except(:genre_names))
    assign_genres(@product, product_params[:genre_names])

    if @product.save
      redirect_to backoffice_products_path, notice: "Producto creado correctamente"
    else
      flash.now[:alert] = @product.errors.full_messages.join(". ")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @product.assign_attributes(product_params.except(:genre_names))
    assign_genres(@product, product_params[:genre_names])

    if @product.save
      redirect_to backoffice_products_path, notice: "Producto actualizado"
    else
      flash.now[:alert] = @product.errors.full_messages.join(". ")
      render :edit, status: :unprocessable_entity
    end
  end

  def increment_stock
    @product.increment!(:stock)
    redirect_to backoffice_products_path
  end

  def decrement_stock
    @product.update(stock: [@product.stock - 1, 0].max)
    redirect_to backoffice_products_path
  end


	def soft_delete
		if @product.removed_at
			redirect_to backoffice_products_path, alert: "Ya está eliminado"
		else
			@product.update(removed_at: Date.current, stock: 0)
			redirect_to backoffice_products_path, notice: "Producto marcado como eliminado"
		end
	end

  def restore
    if @product.removed_at.nil?
      redirect_to backoffice_products_path, alert: "El producto ya está disponible"
    else
      @product.update(removed_at: nil)
      redirect_to backoffice_products_path, notice: "Producto restaurado correctamente"
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    permitted = params.require(:product)
                      .permit(:name, :description, :author, :price, :stock, :format, :condition, :inventory_entry_date, :genre_names, :audio_sample, images: [])

    if permitted.key?(:images)
      images_param = permitted[:images]
      if images_param.blank? || (images_param.respond_to?(:all?) && images_param.all?(&:blank?))
        permitted.delete(:images)
      end
    end

    permitted
  end

  def assign_genres(product, raw_names)
    names = raw_names.to_s.split(",").map { |n| n.strip }.reject(&:blank?).uniq
    return if names.empty?
    product.genres = names.map { |n| Genre.find_or_create_by(name: n) }
  end

  def set_product_with_images
    @product = Product.includes(images_attachments: :blob).find(params[:id])
  end
end
