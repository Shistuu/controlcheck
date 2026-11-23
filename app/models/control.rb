class Control < ApplicationRecord
  has_many :results, dependent: :destroy

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
