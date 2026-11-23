# Controlcheck

Controlcheck checks a GitHub organization against five SOC 2-style controls and
keeps every run in PostgreSQL, so you can see when a control started failing.
For a failed control it can ask Claude (Anthropic API) to draft fix steps. A
person edits and approves the draft before it counts as evidence.

## Controls

1. **Default branch protection**: every repo has protection on its default branch.
2. **Required pull request reviews**: the default branch needs at least one approving review.
3. **Organization requires 2FA**: `two_factor_requirement_enabled` is true for the org.
4. **Dependabot alerts enabled**: vulnerability alerts are on for every repo.
5. **No unapproved public repos**: public repos must be on the org's allowlist (set on the org's edit page).

Each result stores pass/fail plus the raw data the check looked at. GitHub API
errors (for example a 404 when the token can't see a setting) are stored as a
failed result with the reason.

The org page shows each control's latest status and "failing since", which is
the start of the earliest run in the current unbroken run of failures.

## Setup

Needs Ruby 3.3+ (developed on 4.0 from Homebrew), PostgreSQL 16 and Node.

```sh
brew install ruby postgresql@16 node
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/4.0.0/bin:$PATH"
brew services start postgresql@16

bundle install
npm install
bin/rails db:create db:migrate db:seed
```

Seeds add the five controls. To try the UI without a GitHub token, load a fake
org with made-up history:

```sh
bin/rails controlcheck:demo_data
```

## Running

```sh
export GITHUB_TOKEN=...        # see scopes below
export ANTHROPIC_API_KEY=...   # only needed for "Draft fix steps"
bin/dev                        # Rails on :3000 plus the esbuild watcher
```

Add an org in the UI and press "Run checks now", or from the command line:

```sh
bin/rails 'controlcheck:run[your-org-login]'
```

### GitHub token

Use a classic personal access token with the `repo` and `read:org` scopes.
GitHub only shows branch protection and Dependabot alert settings to users with
admin access on the repo, and only returns the 2FA field to org owners (add
`admin:org` for that). Without that access the affected controls fail with the
reason in their details. These checks have only been run against stubbed API
responses so far, not a live org.

GitHub returns 404 both when Dependabot alerts are off and when the token can't
see the setting, so a failure there can mean either.

### Drafting fix steps

"Draft fix steps" on a failed result sends the control and its raw data to the
Messages API (`claude-sonnet-5-5`) and saves the reply as a draft. The reviewer
can edit the text, enter their name and approve, or reject. Only approved
remediations appear on the Evidence page. If `ANTHROPIC_API_KEY` is not set the
page shows an error instead.

There is no login; the reviewer name is typed in by hand.

## Tests

```sh
bin/rails test
npm run typecheck   # type-checks the Stimulus controller written in TypeScript
```

Tests use WebMock to stub the GitHub and Anthropic APIs, so they never touch the
network.
