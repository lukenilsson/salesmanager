class Report < ApplicationRecord
  has_one_attached :file
  validates :file_digest, uniqueness: true
end
