class AiService
  def initialize
    @client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai_api_key || ENV["OPENAI_API_KEY"]
    )
  end

  def chat(messages)
    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: messages,
        temperature: 0.7,
        max_tokens: 1000
      }
    )
    response.dig("choices", 0, "message", "content")
  end

  def chat_stream(messages, &block)
    @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: messages,
        temperature: 0.7,
        max_tokens: 1000,
        stream: proc do |chunk|
          delta = chunk.dig("choices", 0, "delta", "content")
          yield delta if delta
        end
      }
    )
  end
end
