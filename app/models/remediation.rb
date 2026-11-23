class Remediation < ApplicationRecord
  STATUSES = %w[draft approved rejected].freeze

  belongs_to :result

  validates :draft_text, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :approved_by, :final_text, presence: true, if: :approved?

  scope :approved, -> { where(status: "approved") }

  def approved?
    status == "approved"
  end

  def draft?
    status == "draft"
  end

  def approve!(reviewer:, text:)
    update!(status: "approved", approved_by: reviewer, approved_at: Time.current, final_text: text)
  end

  def reject!
    update!(status: "rejected")
  end
end
