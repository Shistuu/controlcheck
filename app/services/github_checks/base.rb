module GithubChecks
  # Each check gets an Octokit client and an Organization and returns an Outcome.
  # GitHub API errors become a failed Outcome with the reason instead of raising.
  class Base
    def initialize(client:, organization:)
      @client = client
      @organization = organization
    end

    def call
      run
    rescue Octokit::Error, Faraday::Error => e
      Outcome.new(passed: false, details: { "error" => e.class.name, "message" => e.message })
    end

    private

    attr_reader :client, :organization

    def org_login
      organization.github_login
    end

    def repos
      @repos ||= client.org_repos(org_login, type: "all")
    end

    # Runs the block for every repo. A 403/404 on one repo is recorded as an
    # error for that repo so the rest of the org still gets checked.
    def per_repo
      repos.map do |repo|
        begin
          { "repo" => repo[:full_name] }.merge(yield(repo))
        rescue Octokit::NotFound, Octokit::Forbidden => e
          { "repo" => repo[:full_name], "ok" => false, "error" => "#{e.class.name}: #{e.message}" }
        end
      end
    end

    def outcome_from(rows)
      failing = rows.reject { |row| row["ok"] }.map { |row| row["repo"] }
      Outcome.new(
        passed: failing.empty?,
        details: { "repos_checked" => rows.size, "failing_repos" => failing, "repos" => rows }
      )
    end
  end
end
