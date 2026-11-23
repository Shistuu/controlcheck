require "test_helper"

class CheckRunnerTest < ActiveSupport::TestCase
  test "stores one result per control with the raw details" do
    stub_repos([ repo("api"), repo("docs", private: false) ])
    stub_protection("acme/api", { required_pull_request_reviews: { required_approving_review_count: 1 } })
    stub_not_protected("acme/docs")
    stub_org({ login: "acme", two_factor_requirement_enabled: true })
    stub_vulnerability_alerts("acme/api", enabled: true)
    stub_vulnerability_alerts("acme/docs", enabled: true)

    run = CheckRunner.new(organizations(:acme), client: github_client).call

    assert_not_nil run.finished_at
    assert_equal 5, run.results.count

    by_key = run.results.includes(:control).index_by { |r| r.control.key }
    assert_not by_key["branch_protection"].passed
    assert_equal [ "acme/docs" ], by_key["branch_protection"].details["failing_repos"]
    assert_not by_key["required_reviews"].passed
    assert by_key["org_two_factor"].passed
    assert by_key["dependabot_alerts"].passed
    assert by_key["no_public_repos"].passed
  end

  test "keeps running other controls when one API call fails" do
    stub_repos([ repo("api") ])
    stub_protection("acme/api", { required_pull_request_reviews: { required_approving_review_count: 1 } })
    stub_request(:get, "https://api.github.com/orgs/acme").to_return(json({ message: "Not Found" }, status: 404))
    stub_vulnerability_alerts("acme/api", enabled: true)

    run = CheckRunner.new(organizations(:acme), client: github_client).call

    assert_equal 5, run.results.count
    two_factor = run.results.find_by(control: controls(:org_two_factor))
    assert_not two_factor.passed
    assert_equal "Octokit::NotFound", two_factor.details["error"]
  end

  test "raises a clear error when GITHUB_TOKEN is missing" do
    with_env("GITHUB_TOKEN" => nil) do
      assert_raises(GithubChecks::MissingToken) { CheckRunner.new(organizations(:acme)) }
    end
  end
end
