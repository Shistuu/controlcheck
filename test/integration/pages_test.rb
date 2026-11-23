require "test_helper"

class PagesTest < ActionDispatch::IntegrationTest
  setup do
    @org = organizations(:acme)
  end

  test "organization page shows latest status and failing since date" do
    control = controls(:org_two_factor)
    create_run(@org, Time.zone.local(2026, 11, 1, 9), control => true)
    create_run(@org, Time.zone.local(2026, 11, 5, 9), control => false)
    create_run(@org, Time.zone.local(2026, 11, 9, 9), control => false)

    get organization_path(@org)

    assert_response :success
    assert_match "failing since November 05, 2026", response.body
  end

  test "index and new pages render" do
    get root_path
    assert_response :success
    assert_match "Acme", response.body

    get new_organization_path
    assert_response :success
  end

  test "run checks button shows a flash error without GITHUB_TOKEN" do
    with_env("GITHUB_TOKEN" => nil) do
      post organization_check_runs_path(@org)
    end

    assert_redirected_to organization_path(@org)
    follow_redirect!
    assert_match "GITHUB_TOKEN is not set", response.body
  end

  test "run checks button runs the checks when a token is set" do
    stub_repos([ repo("api") ])
    stub_protection("acme/api", { required_pull_request_reviews: { required_approving_review_count: 1 } })
    stub_org({ login: "acme", two_factor_requirement_enabled: true })
    stub_vulnerability_alerts("acme/api", enabled: true)

    with_env("GITHUB_TOKEN" => "test-token") do
      assert_difference -> { @org.check_runs.count }, 1 do
        post organization_check_runs_path(@org)
      end
    end
    assert_equal 5, @org.check_runs.last.results.count
  end
end
