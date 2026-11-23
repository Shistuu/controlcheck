require "test_helper"

class GithubChecks::NoPublicReposTest < ActiveSupport::TestCase
  def check
    GithubChecks::NoPublicRepos.new(client: github_client, organization: organizations(:acme)).call
  end

  test "passes when the only public repo is on the allowlist" do
    stub_repos([ repo("api"), repo("docs", private: false) ])

    outcome = check

    assert outcome.passed
    assert_equal [ "docs" ], outcome.details["public_repos"]
  end

  test "fails when a public repo is not on the allowlist" do
    stub_repos([ repo("api", private: false), repo("docs", private: false) ])

    outcome = check

    assert_not outcome.passed
    assert_equal [ "api" ], outcome.details["not_allowed"]
  end
end
