module GithubChecks
  # Control: no public repos except the ones on the organization's allowlist.
  class NoPublicRepos < Base
    private

    def run
      allowlist = organization.public_repo_allowlist
      public_repos = repos.reject { |repo| repo[:private] }.map { |repo| repo[:name] }
      not_allowed = public_repos - allowlist
      Outcome.new(
        passed: not_allowed.empty?,
        details: {
          "repos_checked" => repos.size,
          "public_repos" => public_repos,
          "allowlist" => allowlist,
          "not_allowed" => not_allowed
        }
      )
    end
  end
end
