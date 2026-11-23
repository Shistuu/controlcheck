namespace :controlcheck do
  desc "Run all control checks for a GitHub org, e.g. bin/rails 'controlcheck:run[my-org]'"
  task :run, [ :org_login ] => :environment do |_task, args|
    login = args[:org_login].presence or abort "Usage: bin/rails 'controlcheck:run[org_login]'"

    begin
      client = GithubChecks.client
    rescue GithubChecks::MissingToken => e
      abort e.message
    end

    organization = Organization.find_or_create_by!(github_login: login) { |org| org.name = login }
    run = CheckRunner.new(organization, client: client).call

    run.results.includes(:control).order(:control_id).each do |result|
      status = result.passed? ? "PASS" : "FAIL"
      puts "#{status}  #{result.control.name}"
      puts "      #{result.details['message']}" if result.details["message"]
    end
  end

  desc "Load a fake organization with a few weeks of made-up runs, for trying the UI without a token"
  task demo_data: :environment do
    load Rails.root.join("db/seeds.rb")

    org = Organization.find_or_create_by!(github_login: "demo-org") do |o|
      o.name = "Demo Org (fake data)"
      o.public_repo_allowlist = [ "docs-site" ]
    end
    org.check_runs.destroy_all

    controls = Control.all.index_by(&:key)
    # true = pass. Oldest run first. dependabot_alerts starts failing on day 3.
    history = {
      "branch_protection" => [ true, true, true, true, true ],
      "required_reviews" => [ false, false, true, false, false ],
      "org_two_factor" => [ true, true, true, true, true ],
      "dependabot_alerts" => [ true, true, false, false, false ],
      "no_public_repos" => [ true, true, true, true, false ]
    }

    5.times do |i|
      started = (14 - i * 3).days.ago.change(hour: 9)
      run = org.check_runs.create!(started_at: started, finished_at: started + 40.seconds)
      history.each do |key, outcomes|
        passed = outcomes[i]
        run.results.create!(
          control: controls.fetch(key),
          passed: passed,
          details: { "note" => "fake demo data", "repos_checked" => 4, "failing_repos" => passed ? [] : [ "demo-org/api" ] }
        )
      end
    end

    puts "Demo org created with #{org.check_runs.count} runs: #{org.id}"
  end
end
