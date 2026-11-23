class CheckRunsController < ApplicationController
  def create
    organization = Organization.find(params[:organization_id])
    CheckRunner.new(organization).call
    redirect_to organization, notice: "Check run finished."
  rescue GithubChecks::MissingToken
    redirect_to organization, alert: "GITHUB_TOKEN is not set. Export it and restart the server to run checks."
  end
end
