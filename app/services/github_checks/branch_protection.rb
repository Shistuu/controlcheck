module GithubChecks
  # Control: the default branch of every repo has branch protection turned on.
  class BranchProtection < Base
    private

    def run
      rows = per_repo do |repo|
        protection = client.branch_protection(repo[:full_name], repo[:default_branch])
        { "default_branch" => repo[:default_branch], "ok" => !protection.nil? }
      end
      outcome_from(rows)
    end
  end
end
