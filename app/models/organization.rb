class Organization < ApplicationRecord
  has_many :check_runs, dependent: :destroy
  has_many :results, through: :check_runs

  validates :name, presence: true
  validates :github_login, presence: true, uniqueness: true

  # The allowlist is edited as a comma-separated string in the form.
  def public_repo_allowlist_text
    public_repo_allowlist.join(", ")
  end

  def public_repo_allowlist_text=(text)
    self.public_repo_allowlist = text.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  # Results for one control, newest run first.
  def history_for(control)
    results.where(control: control).includes(:check_run).order("check_runs.started_at DESC")
  end

  def latest_result_for(control)
    history_for(control).first
  end

  # Start time of the earliest run in the current unbroken streak of failures.
  # Returns nil if the latest result passed or there are no results.
  def failing_since(control)
    streak_start = nil
    history_for(control).each do |result|
      break if result.passed?
      streak_start = result.check_run.started_at
    end
    streak_start
  end
end
