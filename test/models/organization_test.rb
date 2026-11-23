require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  setup do
    @org = organizations(:acme)
    @control = controls(:org_two_factor)
  end

  test "failing_since is nil with no runs" do
    assert_nil @org.failing_since(@control)
  end

  test "failing_since is nil when the latest result passed" do
    create_run(@org, 3.days.ago, @control => false)
    create_run(@org, 1.day.ago, @control => true)

    assert_nil @org.failing_since(@control)
  end

  test "failing_since is the start of the current failing streak, not the first failure ever" do
    create_run(@org, 10.days.ago, @control => false)
    create_run(@org, 8.days.ago, @control => true)
    streak_start = create_run(@org, 6.days.ago, @control => false)
    create_run(@org, 4.days.ago, @control => false)
    create_run(@org, 2.days.ago, @control => false)

    assert_equal streak_start.started_at, @org.failing_since(@control)
  end

  test "failing_since only looks at the given control" do
    other = controls(:branch_protection)
    create_run(@org, 5.days.ago, @control => true, other => false)
    latest = create_run(@org, 1.day.ago, @control => false, other => false)

    assert_equal latest.started_at, @org.failing_since(@control)
    assert_equal 5.days.ago.to_date, @org.failing_since(other).to_date
  end

  test "allowlist text is split on commas" do
    @org.public_repo_allowlist_text = "docs, site ,, blog"
    assert_equal %w[docs site blog], @org.public_repo_allowlist
  end
end
