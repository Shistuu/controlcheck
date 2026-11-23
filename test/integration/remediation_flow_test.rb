require "test_helper"

class RemediationFlowTest < ActionDispatch::IntegrationTest
  MESSAGES_URL = "https://api.anthropic.com/v1/messages".freeze

  setup do
    @org = organizations(:acme)
    run = create_run(@org, 1.day.ago, controls(:dependabot_alerts) => false)
    @result = run.results.first
  end

  def stub_claude(text)
    body = {
      id: "msg_test",
      type: "message",
      role: "assistant",
      model: "claude-sonnet-5-5",
      content: [ { type: "text", text: text } ],
      stop_reason: "end_turn",
      stop_sequence: nil,
      usage: { input_tokens: 10, output_tokens: 20 }
    }
    stub_request(:post, MESSAGES_URL)
      .with(body: hash_including("model" => "claude-sonnet-5-5"))
      .to_return(status: 200, body: body.to_json, headers: { "Content-Type" => "application/json" })
  end

  test "a draft is not evidence until a reviewer approves it" do
    stub_claude("1. Enable Dependabot alerts on acme/api.")

    with_env("ANTHROPIC_API_KEY" => "test-key") do
      post result_remediations_path(@result)
    end
    remediation = Remediation.last
    assert_redirected_to edit_remediation_path(remediation)
    assert_equal "draft", remediation.status

    get evidence_organization_path(@org)
    assert_response :success
    assert_no_match "Enable Dependabot alerts", response.body

    patch approve_remediation_path(remediation),
      params: { approved_by: "Sam Reviewer", final_text: "1. Enable Dependabot alerts on acme/api (edited)." }
    assert_redirected_to result_path(@result)
    remediation.reload
    assert_equal "approved", remediation.status
    assert_equal "Sam Reviewer", remediation.approved_by
    assert_not_nil remediation.approved_at

    get evidence_organization_path(@org)
    assert_match "Enable Dependabot alerts on acme/api (edited).", response.body
    assert_match "Sam Reviewer", response.body
  end

  test "approving without a reviewer name is rejected" do
    remediation = @result.remediations.create!(draft_text: "1. Do the thing.")

    patch approve_remediation_path(remediation), params: { approved_by: "", final_text: "1. Do the thing." }

    assert_response :unprocessable_entity
    assert_equal "draft", remediation.reload.status
  end

  test "a rejected draft never shows on the evidence page" do
    remediation = @result.remediations.create!(draft_text: "1. Rejected steps.")

    patch reject_remediation_path(remediation)

    assert_equal "rejected", remediation.reload.status
    get evidence_organization_path(@org)
    assert_no_match "Rejected steps", response.body
  end

  test "shows a flash error when ANTHROPIC_API_KEY is not set" do
    with_env("ANTHROPIC_API_KEY" => nil) do
      post result_remediations_path(@result)
    end

    assert_redirected_to result_path(@result)
    follow_redirect!
    assert_match "ANTHROPIC_API_KEY is not set", response.body
    assert_equal 0, Remediation.count
  end
end
