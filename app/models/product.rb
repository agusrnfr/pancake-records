class Product < ApplicationRecord
	has_and_belongs_to_many :genres
  has_many :sale_products
  has_many :sales, through: :sale_products

	has_many_attached :images
  has_one_attached :audio_sample

  enum :format, { vinyl: 0, cd: 1 }
  enum :condition, { used: 0, brand_new: 1 }

  attr_accessor :genre_names

  validates :name, :author, :price, :stock, :format, :condition, :inventory_entry_date, presence: true
	validates :price, numericality: { greater_than_or_equal_to: 0 }
	validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

	validates :images, attached: true, content_type: ['image/png','image/jpeg'], size: { less_than: 6.megabytes , message: 'es demasiado grande (máx 6MB)' }
	validates :audio_sample, content_type: /^audio\/(mpeg|mp3)$/i, size: { less_than: 10.megabytes }, allow_blank: true
	
	ransacker :status, type: :string do |parent|
		Arel.sql <<~SQL
			CASE
				WHEN #{parent.table[:removed_at].not_eq(nil).to_sql} THEN 'eliminado'
				WHEN #{parent.table[:removed_at].eq(nil).and(parent.table[:stock].eq(0)).to_sql} THEN 'sin_stock'
				ELSE 'disponible'
			END
		SQL
	end

	ransacker :year, type: :integer do |parent|
		Arel.sql("CAST(strftime('%Y', inventory_entry_date) AS INTEGER)")
	end

  def self.ransackable_attributes(auth_object = nil)
    ["author", "condition", "created_at", "description", "format", "id", "inventory_entry_date", "name", "price", "removed_at", "status", "stock", "updated_at", "year"]
  end

	def self.ransackable_associations(auth_object = nil)
    ["audio_sample_attachment", "audio_sample_blob", "genres", "images_attachments", "images_blobs", "sale_products", "sales"]
  end

	def condition_name
		I18n.t("activerecord.enums.product.condition.#{condition}")
	end

	def format_name
		I18n.t("activerecord.enums.product.format.#{format}")
	end

  def genre_names
    @genre_names.present? ? @genre_names : genres.pluck(:name).join(", ")
  end

  # Método para obtener la imagen de portada (primera imagen)
  def cover_image
    images.first
  end

  # Método para verificar si el producto está disponible
  def available?
    removed_at.nil? && stock > 0
  end

end