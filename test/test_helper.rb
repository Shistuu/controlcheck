ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

WebMock.disable_net_connect!(allow_localhost: true)

module GithubStubs
  API = "https://api.github.com".freeze

  def github_client
    Octokit::Client.new(access_token: "test-token", auto_paginate: true)
  end

  def json(body, status: 200)
    { status: status, body: body.to_json, headers: { "Content-Type" => "application/json" } }
  end

  def repo(name, private: true, branch: "main")
    { name: name, full_name: "acme/#{name}", private: private, default_branch: branch }
  end

  def stub_repos(repos, login: "acme")
    stub_request(:get, %r{\A#{API}/orgs/#{login}/repos}).to_return(json(repos))
  end

  def stub_protection(full_name, body, status: 200, branch: "main")
    stub_request(:get, "#{API}/repos/#{full_name}/branches/#{branch}/protection")
      .to_return(json(body, status: status))
  end

  def stub_not_protected(full_name, branch: "main")
    stub_protection(full_name, { message: "Branch not protected" }, status: 404, branch: branch)
  end

  def stub_vulnerability_alerts(full_name, enabled:)
    stub_request(:get, "#{API}/repos/#{full_name}/vulnerability-alerts")
      .to_return(status: enabled ? 204 : 404, body: "")
  end

  def stub_org(body, login: "acme")
    stub_request(:get, "#{API}/orgs/#{login}").to_return(json(body))
  end
end

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    include GithubStubs

    # Sets ENV vars for the duration of a block and restores them afterwards.
    def with_env(vars)
      old = vars.keys.to_h { |key| [ key, ENV[key] ] }
      vars.each { |key, value| ENV[key] = value }
      yield
    ensure
      old.each { |key, value| ENV[key] = value }
    end

    def create_run(organization, started_at, outcomes)
      run = organization.check_runs.create!(started_at: started_at, finished_at: started_at + 1.minute)
      outcomes.each do |control, passed|
        run.results.create!(control: control, passed: passed, details: {})
      end
      run
    end
  end
end
