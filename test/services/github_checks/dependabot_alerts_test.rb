require "test_helper"

class GithubChecks::DependabotAlertsTest < ActiveSupport::TestCase
  def check
    GithubChecks::DependabotAlerts.new(client: github_client, organization: organizations(:acme)).call
  end

  test "passes when alerts are enabled on every repo" do
    stub_repos([ repo("api"), repo("web") ])
    stub_vulnerability_alerts("acme/api", enabled: true)
    stub_vulnerability_alerts("acme/web", enabled: true)

    assert check.passed
  end

  test "fails and names repos with alerts disabled" do
    stub_repos([ repo("api"), repo("web") ])
    stub_vulnerability_alerts("acme/api", enabled: true)
    stub_vulnerability_alerts("acme/web", enabled: false)

    outcome = check

    assert_not outcome.passed
    assert_equal [ "acme/web" ], outcome.details["failing_repos"]
  end
end
