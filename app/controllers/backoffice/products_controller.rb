class Backoffice::ProductsController < ApplicationController
	include ActionView::RecordIdentifier
  before_action :set_product, only: [:show, :edit, :update, :soft_delete, :restore]
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

    if @product.save && apply_image_changes(@product)
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

    if @product.save && apply_image_changes(@product)
      redirect_to backoffice_products_path, notice: "Producto actualizado"
    else
      flash.now[:alert] = @product.errors.full_messages.join(". ")
      render :edit, status: :unprocessable_entity
    end
  end

	def soft_delete
    if @product.removed_at
      redirect_back fallback_location: backoffice_products_path, alert: "Ya está eliminado"
    else
      @product.update(removed_at: Date.current, stock: 0)
      redirect_back fallback_location: backoffice_products_path, notice: "Producto marcado como eliminado"
    end
	end

  def restore
    if @product.removed_at.nil?
      redirect_back fallback_location: backoffice_products_path, alert: "El producto ya está disponible"
    else
      @product.update(removed_at: nil)
      redirect_back fallback_location: backoffice_products_path, notice: "Producto restaurado correctamente"
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    permitted = params.require(:product)
                      .permit(:name, :description, :author, :price, :stock, :format, :condition, :inventory_entry_date, :genre_names, :audio_sample, :image_order, :image_remove_ids, images: [])

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

  def apply_image_changes(product)
    order = product.image_order.to_s
    remove = product.image_remove_ids.to_s

    attachments = product.images.attachments.index_by { |att| att.id.to_s }

    ids_for_order = order.split(",").map(&:strip).reject(&:blank?)
    ids_for_remove = remove.split(",").map(&:strip).reject(&:blank?)

    attachments_to_remove = ids_for_remove.map { |id| attachments[id] }.compact
    remaining_count = attachments.size - attachments_to_remove.size

    if attachments.any? && remaining_count <= 0
      product.errors.add(:base, "Debe mantenerse al menos una imagen para el producto")
      return false
    end

    ids_for_order.each_with_index do |id, index|
      attachment = attachments[id]
      next unless attachment && attachment.respond_to?(:position)

      attachment.update_column(:position, index)
    end

    attachments_to_remove.each(&:purge)

    true
  end
end
