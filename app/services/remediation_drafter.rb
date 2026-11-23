# Asks the LLM for fix steps for a failed result and saves them as a draft.
class RemediationDrafter
  SYSTEM_PROMPT = <<~TEXT.freeze
    You help an engineer fix a failed security control on their GitHub organization.
    Write short, numbered fix steps that are specific to the data provided.
    Name the exact repos or settings involved. Mention the GitHub UI path or API
    call for each step. Do not invent repos or settings that are not in the data.
  TEXT

  def initialize(llm_client: LlmClient.new)
    @llm_client = llm_client
  end

  def call(result)
    raise ArgumentError, "result passed; nothing to fix" if result.passed?

    text = @llm_client.complete(system: SYSTEM_PROMPT, prompt: prompt_for(result))
    result.remediations.create!(draft_text: text, status: "draft")
  end

  private

  def prompt_for(result)
    control = result.control
    <<~TEXT
      Control: #{control.name} (#{control.key})
      What it requires: #{control.description}
      Organization: #{result.check_run.organization.github_login}

      Raw data the check looked at (JSON):
      #{JSON.pretty_generate(result.details)}
    TEXT
  end
end
