class RemediationsController < ApplicationController
  before_action :set_remediation, only: [ :edit, :approve, :reject ]

  def create
    result = Result.find(params[:result_id])
    remediation = RemediationDrafter.new.call(result)
    redirect_to edit_remediation_path(remediation), notice: "Draft created. Review it before approving."
  rescue LlmClient::MissingKey
    redirect_to result, alert: "ANTHROPIC_API_KEY is not set, so fix steps can't be drafted."
  rescue LlmClient::Error => e
    redirect_to result, alert: "Drafting failed: #{e.message}"
  end

  def edit
  end

  def approve
    reviewer = params[:approved_by].to_s.strip
    text = params[:final_text].to_s.strip
    if reviewer.blank? || text.blank?
      flash.now[:alert] = "Reviewer name and fix steps are both required to approve."
      render :edit, status: :unprocessable_entity
    else
      @remediation.approve!(reviewer: reviewer, text: text)
      redirect_to @remediation.result, notice: "Remediation approved and added to evidence."
    end
  end

  def reject
    @remediation.reject!
    redirect_to @remediation.result, notice: "Remediation rejected."
  end

  private

  def set_remediation
    @remediation = Remediation.includes(result: [ :control, { check_run: :organization } ]).find(params[:id])
  end
end
