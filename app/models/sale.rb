class Sale < ApplicationRecord
  belongs_to :employee, class_name: "User"
  has_many :sale_products, dependent: :destroy
  has_many :products, through: :sale_products
  accepts_nested_attributes_for :sale_products, allow_destroy: true, reject_if: :all_blank

  validates :date, :employee_id, presence: true
  
  before_validation :normalize_time
  before_validation :merge_duplicate_products
  before_validation :calculate_total

  def cancel!
    return false if is_cancelled?
    update!(is_cancelled: true)
    restore_stock_on_cancel
    true
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "created_at",
      "date",
      "employee_id",
      "id",
      "total",
      "updated_at",
      "is_cancelled"   
    ]
  end
  

  private

  def normalize_time
    return unless time.present?
    self.time = Time.new(2000, 1, 1, time.hour, time.min, 0)
  end

  def merge_duplicate_products
    return if sale_products.empty?

    grouped = sale_products.group_by(&:product_id)
    
    grouped.each do |product_id, products_list|
      next if products_list.size <= 1
      
      first_product = products_list.first
      total_quantity = products_list.sum(&:quantity)
      
      first_product.quantity = total_quantity
      
      products_list[1..-1].each do |duplicate|
        duplicate.mark_for_destruction
      end
    end
  end

  def calculate_total
    self.total = sale_products.reject(&:marked_for_destruction?).sum { |sp| sp.total_line_price }
  end

  def restore_stock_on_cancel
    return unless is_cancelled?
    sale_products.reload.each(&:restore_stock)
  end
  def self.ransackable_associations(auth_object = nil)
    ["employee", "products", "sale_products"]
  end
  
end