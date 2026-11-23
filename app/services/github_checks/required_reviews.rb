module GithubChecks
  # Control: the default branch requires at least one approving PR review.
  class RequiredReviews < Base
    private

    def run
      rows = per_repo do |repo|
        protection = client.branch_protection(repo[:full_name], repo[:default_branch])
        reviews = protection && protection[:required_pull_request_reviews]
        count = reviews ? reviews[:required_approving_review_count].to_i : 0
        {
          "default_branch" => repo[:default_branch],
          "required_approving_review_count" => count,
          "ok" => count >= 1
        }
      end
      outcome_from(rows)
    end
  end
end
