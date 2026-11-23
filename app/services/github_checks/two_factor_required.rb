module GithubChecks
  # Control: the organization requires 2FA for all members.
  class TwoFactorRequired < Base
    private

    def run
      org = client.organization(org_login)
      enabled = org[:two_factor_requirement_enabled]
      details = { "two_factor_requirement_enabled" => enabled }
      # GitHub only returns this field to org owners; otherwise it is missing.
      if enabled.nil?
        details["message"] = "Field not returned. The token likely lacks owner access (admin:org scope)."
      end
      Outcome.new(passed: enabled == true, details: details)
    end
  end
end
