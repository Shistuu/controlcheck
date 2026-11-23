class ResultsController < ApplicationController
  def show
    @result = Result.includes(:control, :remediations, check_run: :organization).find(params[:id])
    @organization = @result.check_run.organization
  end
end
