module GithubChecks
  class MissingToken < StandardError; end

  # Maps a Control#key to the class that checks it.
  REGISTRY = {
    "branch_protection" => "GithubChecks::BranchProtection",
    "required_reviews" => "GithubChecks::RequiredReviews",
    "org_two_factor" => "GithubChecks::TwoFactorRequired",
    "dependabot_alerts" => "GithubChecks::DependabotAlerts",
    "no_public_repos" => "GithubChecks::NoPublicRepos"
  }.freeze

  def self.for(control_key)
    REGISTRY.fetch(control_key).constantize
  end

  def self.client
    token = ENV["GITHUB_TOKEN"]
    raise MissingToken, "GITHUB_TOKEN is not set" if token.blank?

    Octokit::Client.new(access_token: token, auto_paginate: true)
  end
end
