class Sale < ApplicationRecord
  belongs_to :account
  belongs_to :product
  validates :year, :month, :quantity, presence: true
end
