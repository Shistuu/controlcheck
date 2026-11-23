# Runs every seeded control against one organization and stores the results.
class CheckRunner
  def initialize(organization, client: GithubChecks.client)
    @organization = organization
    @client = client
  end

  def call
    run = @organization.check_runs.create!(started_at: Time.current)

    Control.order(:id).each do |control|
      check = GithubChecks.for(control.key).new(client: @client, organization: @organization)
      outcome = check.call
      run.results.create!(control: control, passed: outcome.passed, details: outcome.details)
    end

    run.update!(finished_at: Time.current)
    run
  end
end
