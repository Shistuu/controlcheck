require "test_helper"

class GithubChecks::TwoFactorRequiredTest < ActiveSupport::TestCase
  def check
    GithubChecks::TwoFactorRequired.new(client: github_client, organization: organizations(:acme)).call
  end

  test "passes when the org requires 2FA" do
    stub_org({ login: "acme", two_factor_requirement_enabled: true })

    assert check.passed
  end

  test "fails when the org does not require 2FA" do
    stub_org({ login: "acme", two_factor_requirement_enabled: false })

    outcome = check

    assert_not outcome.passed
    assert_equal false, outcome.details["two_factor_requirement_enabled"]
  end

  test "fails with an explanation when the field is not visible to the token" do
    stub_org({ login: "acme" })

    outcome = check

    assert_not outcome.passed
    assert_match "admin:org", outcome.details["message"]
  end

  test "fails with the reason on a 403" do
    stub_request(:get, "https://api.github.com/orgs/acme").to_return(json({ message: "Forbidden" }, status: 403))

    outcome = check

    assert_not outcome.passed
    assert_equal "Octokit::Forbidden", outcome.details["error"]
  end
end
