# The five controls the app checks. Safe to run more than once.
controls = [
  {
    key: "branch_protection",
    name: "Default branch protection",
    description: "Every repository has branch protection enabled on its default branch."
  },
  {
    key: "required_reviews",
    name: "Required pull request reviews",
    description: "The default branch requires at least one approving review before merging."
  },
  {
    key: "org_two_factor",
    name: "Organization requires 2FA",
    description: "The GitHub organization requires two-factor authentication for all members."
  },
  {
    key: "dependabot_alerts",
    name: "Dependabot alerts enabled",
    description: "Dependabot (vulnerability) alerts are enabled on every repository."
  },
  {
    key: "no_public_repos",
    name: "No unapproved public repositories",
    description: "No repository is public unless it is on the organization's allowlist."
  }
]

controls.each do |attrs|
  control = Control.find_or_initialize_by(key: attrs[:key])
  control.update!(name: attrs[:name], description: attrs[:description])
end

puts "Seeded #{Control.count} controls."
