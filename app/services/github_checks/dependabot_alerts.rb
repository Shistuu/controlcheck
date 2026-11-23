module GithubChecks
  # Control: Dependabot (vulnerability) alerts are enabled on every repo.
  # Note: GitHub answers 404 both when alerts are off and when the token
  # can't see the setting, so a "false" here can mean either.
  class DependabotAlerts < Base
    private

    def run
      rows = per_repo do |repo|
        { "ok" => client.vulnerability_alerts_enabled?(repo[:full_name]) }
      end
      outcome_from(rows)
    end
  end
end
