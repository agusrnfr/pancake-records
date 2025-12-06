class Sale < ApplicationRecord
  belongs_to :employee, class_name: "User"
  has_many :sale_products, dependent: :destroy
  has_many :products, through: :sale_products
  accepts_nested_attributes_for :sale_products, allow_destroy: true, reject_if: :all_blank

  validates :date, :employee_id, presence: true
  
  before_validation :calculate_total

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

  def calculate_total
    self.total = sale_products.sum { |sp| sp.total_line_price }
  end
  def self.ransackable_associations(auth_object = nil)
    ["employee", "products", "sale_products"]
  end
  
end