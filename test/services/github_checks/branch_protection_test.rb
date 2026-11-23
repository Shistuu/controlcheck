require "test_helper"

class GithubChecks::BranchProtectionTest < ActiveSupport::TestCase
  def check
    GithubChecks::BranchProtection.new(client: github_client, organization: organizations(:acme)).call
  end

  test "passes when every default branch is protected" do
    stub_repos([ repo("api"), repo("web", branch: "trunk") ])
    stub_protection("acme/api", { url: "x" })
    stub_protection("acme/web", { url: "x" }, branch: "trunk")

    outcome = check

    assert outcome.passed
    assert_equal 2, outcome.details["repos_checked"]
    assert_empty outcome.details["failing_repos"]
  end

  test "fails and names the repo when a default branch is not protected" do
    stub_repos([ repo("api"), repo("web") ])
    stub_protection("acme/api", { url: "x" })
    stub_not_protected("acme/web")

    outcome = check

    assert_not outcome.passed
    assert_equal [ "acme/web" ], outcome.details["failing_repos"]
  end

  test "records a 404 on one repo as a failure with the reason" do
    stub_repos([ repo("api") ])
    stub_protection("acme/api", { message: "Not Found" }, status: 404)

    outcome = check

    assert_not outcome.passed
    assert_match "Octokit::NotFound", outcome.details["repos"].first["error"]
  end

  test "turns an error listing repos into a failed outcome instead of raising" do
    stub_request(:get, %r{api.github.com/orgs/acme/repos}).to_return(json({ message: "Not Found" }, status: 404))

    outcome = check

    assert_not outcome.passed
    assert_equal "Octokit::NotFound", outcome.details["error"]
  end
end
