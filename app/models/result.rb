class Result < ApplicationRecord
  belongs_to :check_run
  belongs_to :control
  has_many :remediations, dependent: :destroy

  validates :passed, inclusion: { in: [ true, false ] }

  def failed?
    !passed?
  end
end
