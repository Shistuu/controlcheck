require "test_helper"

class GithubChecks::RequiredReviewsTest < ActiveSupport::TestCase
  def check
    GithubChecks::RequiredReviews.new(client: github_client, organization: organizations(:acme)).call
  end

  test "passes when the default branch requires an approving review" do
    stub_repos([ repo("api") ])
    stub_protection("acme/api", { required_pull_request_reviews: { required_approving_review_count: 1 } })

    outcome = check

    assert outcome.passed
    assert_equal 1, outcome.details["repos"].first["required_approving_review_count"]
  end

  test "fails when protection exists but reviews are not required" do
    stub_repos([ repo("api"), repo("web") ])
    stub_protection("acme/api", { required_pull_request_reviews: { required_approving_review_count: 2 } })
    stub_protection("acme/web", { enforce_admins: { enabled: true } })

    outcome = check

    assert_not outcome.passed
    assert_equal [ "acme/web" ], outcome.details["failing_repos"]
  end

  test "fails when the branch is not protected at all" do
    stub_repos([ repo("api") ])
    stub_not_protected("acme/api")

    assert_not check.passed
  end
end
