require "test_helper"

class RemediationDrafterTest < ActiveSupport::TestCase
  class FakeLlm
    attr_reader :prompt

    def complete(system:, prompt:)
      @prompt = prompt
      "1. Turn on 2FA in org settings."
    end
  end

  setup do
    run = create_run(organizations(:acme), 1.day.ago, controls(:org_two_factor) => false)
    @result = run.results.first
    @result.update!(details: { "two_factor_requirement_enabled" => false })
  end

  test "saves a draft remediation with the model's text" do
    llm = FakeLlm.new

    remediation = RemediationDrafter.new(llm_client: llm).call(@result)

    assert_equal "draft", remediation.status
    assert_equal "1. Turn on 2FA in org settings.", remediation.draft_text
    assert_includes llm.prompt, "org_two_factor"
    assert_includes llm.prompt, "\"two_factor_requirement_enabled\": false"
  end

  test "refuses to draft for a passing result" do
    @result.update!(passed: true)

    assert_raises(ArgumentError) { RemediationDrafter.new(llm_client: FakeLlm.new).call(@result) }
  end
end
