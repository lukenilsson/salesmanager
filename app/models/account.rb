class Account < ApplicationRecord
  has_many :sales, dependent: :destroy
  has_many :products, through: :sales
  validates :name, presence: true, uniqueness: true
end
