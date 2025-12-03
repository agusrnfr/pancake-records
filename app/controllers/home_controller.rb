class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  
  def index
    base_scope = Product.where(removed_at: nil)
    
    @q = base_scope.ransack(params[:q])
    @products = @q.result(distinct: true)
                  .includes(:genres, images_attachments: :blob)
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(12)
    
    @genres = Genre.joins(:products)
                   .where(products: { removed_at: nil })
                   .distinct
                   .order(:name)
    
    @formats = Product.where(removed_at: nil).distinct.pluck(:format)
    @conditions = Product.where(removed_at: nil).distinct.pluck(:condition)
  end
  
  def show
    @product = Product.includes(:genres, images_attachments: :blob, audio_sample_attachment: :blob)
                      .find(params[:id])
    
    if @product.removed_at.present?
      redirect_to root_path, alert: "Este producto no está disponible"
      return
    end
    
    base_scope = Product.where(removed_at: nil).where.not(id: @product.id, stock: 0)
    
    genre_ids = @product.genre_ids
    if genre_ids.any?
      related_by_genre = base_scope.joins(:genres)
                                   .where(genres: { id: genre_ids })
                                   .distinct
                                   .limit(4)
                                   .includes(:genres, images_attachments: :blob)
      
      if related_by_genre.count >= 4
        @related_products = related_by_genre
      else
        remaining = 4 - related_by_genre.count
        related_by_format = base_scope.where(format: @product.format)
                                      .where.not(id: related_by_genre.select(:id))
                                      .limit(remaining)
                                      .includes(:genres, images_attachments: :blob)
        @related_products = related_by_genre.to_a + related_by_format.to_a
      end
    else
      @related_products = base_scope.where(format: @product.format)
                                    .limit(4)
                                    .includes(:genres, images_attachments: :blob)
    end
  end
end