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
  validate  :must_have_at_least_one_image

  scope :search, ->(term) {
    return all if term.blank?
    where("LOWER(name) LIKE :t OR LOWER(author) LIKE :t", t: "%#{term.downcase.strip}%")
  }

  scope :with_status, ->(status) {
    case status
    when "eliminado" then where.not(removed_at: nil)
    when "sin_stock" then where(removed_at: nil, stock: 0)
    when "activo" then where(removed_at: nil).where.not(stock: 0)
    else
      all
    end
  }

  scope :with_format, ->(fmt) {
    return all if fmt.blank? || !formats.keys.include?(fmt)
    where(format: formats[fmt])
  }

  scope :with_condition, ->(cond) {
    return all if cond.blank? || !conditions.keys.include?(cond)
    where(condition: conditions[cond])
  }

  scope :from_date, ->(date_str) {
    return all if date_str.blank?
    date = Date.parse(date_str) rescue nil
    date ? where("inventory_entry_date >= ?", date) : all
  }

  scope :to_date, ->(date_str) {
    return all if date_str.blank?
    date = Date.parse(date_str) rescue nil
    date ? where("inventory_entry_date <= ?", date) : all
  }

  def self.filtered(params)
    search(params[:q])
      .with_status(params[:status])
      .with_format(params[:format])
      .with_condition(params[:condition])
      .from_date(params[:from_date])
      .to_date(params[:to_date])
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

  private

  def must_have_at_least_one_image
    errors.add(:images, "debe incluir al menos una imagen") unless images.attached?
  end

end