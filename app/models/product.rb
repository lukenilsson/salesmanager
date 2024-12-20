class Product < ApplicationRecord
  has_many :sales, dependent: :destroy
  has_many :accounts, through: :sales
  validates :name, presence: true, uniqueness: true
end
