class CheckRun < ApplicationRecord
  belongs_to :organization
  has_many :results, dependent: :destroy

  validates :started_at, presence: true
end
