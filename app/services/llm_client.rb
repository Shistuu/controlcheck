# Thin wrapper around the Anthropic Messages API.
class LlmClient
  MODEL = :"claude-sonnet-5-5"

  class MissingKey < StandardError; end
  class Error < StandardError; end

  def initialize(api_key: ENV["ANTHROPIC_API_KEY"])
    raise MissingKey, "ANTHROPIC_API_KEY is not set" if api_key.blank?

    @client = Anthropic::Client.new(api_key: api_key)
  end

  def complete(system:, prompt:)
    message = @client.messages.create(
      model: MODEL,
      max_tokens: 8000,
      system_: system,
      messages: [ { role: "user", content: prompt } ]
    )
    raise Error, "The model declined this request" if message.stop_reason == :refusal

    message.content.select { |block| block.type == :text }.map(&:text).join("\n").strip
  rescue Anthropic::Errors::APIError => e
    raise Error, e.message
  end
end
