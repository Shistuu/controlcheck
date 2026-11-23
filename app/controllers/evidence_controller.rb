class EvidenceController < ApplicationController
  def show
    @organization = Organization.find(params[:id])
    @runs = @organization.check_runs.includes(results: :control).order(started_at: :desc)
    @remediations = Remediation.approved
      .joins(result: :check_run)
      .where(check_runs: { organization_id: @organization.id })
      .includes(result: :control)
      .order(approved_at: :desc)
  end
end
