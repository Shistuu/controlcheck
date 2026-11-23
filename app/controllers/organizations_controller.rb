class OrganizationsController < ApplicationController
  before_action :set_organization, only: [ :show, :edit, :update ]

  def index
    @organizations = Organization.order(:name)
  end

  def show
    @controls = Control.order(:id)
    @last_run = @organization.check_runs.order(started_at: :desc).first
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      redirect_to @organization, notice: "Organization added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: "Organization updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.expect(organization: [ :name, :github_login, :public_repo_allowlist_text ])
  end
end
