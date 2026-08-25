class AiService
  def initialize
    @use_mock = !ENV["OPENAI_API_KEY"].present?
  end

  def chat(messages)
    return mock_response(messages) if @use_mock

    client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: messages,
        temperature: 0.7,
        max_tokens: 1000
      }
    )
    response.dig("choices", 0, "message", "content")
  end

  def stream_chat(messages, &block)
    return mock_stream(messages, &block) if @use_mock

    client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    collected = +""

    client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: messages,
        temperature: 0.7,
        max_tokens: 1000,
        stream: true
      }
    ) do |chunk, _index|
      delta = chunk.dig("choices", 0, "delta", "content")
      next unless delta

      collected << delta
      block.call(delta, collected)
    end

    collected
  end

  private

  def mock_stream(messages, &block)
    response = mock_response(messages)
    words = response.split(" ")
    collected = +""

    words.each_with_index do |word, i|
      chunk = i.zero? ? word : " #{word}"
      collected << chunk
      block.call(chunk, collected)
      sleep(0.03)
    end

    collected
  end

  def mock_response(messages)
    last_message = messages.last[:content].downcase

    case last_message
    when /hello|hi|hey/
      "Hello! I'm your AI writing assistant. I can help you write blog posts, emails, code documentation, and more. What would you like to work on?"
    when /blog|post|article/
      "Here's a blog post outline:\n\n1. Introduction - Hook the reader with a compelling question\n2. Problem Statement - What pain point are you solving?\n3. Solution - Your unique approach\n4. Key Takeaways - Summary of main points\n5. Call to Action - What should readers do next?\n\nWant me to expand on any section?"
    when /email|mail/
      "Here's a professional email template:\n\nSubject: [Your Topic]\n\nHi [Name],\n\nI hope this email finds you well. I'm reaching out regarding [purpose].\n\n[Body paragraph with key information]\n\nPlease let me know if you have any questions or need additional information.\n\nBest regards,\n[Your Name]"
    when /code|document|readme/
      "Here's how to write good code documentation:\n\n1. **Purpose** - What does this code do?\n2. **Usage** - How to use it with examples\n3. **Parameters** - Input/output documentation\n4. **Edge Cases** - What to watch out for\n\nGood documentation answers questions before they're asked."
    when /help|what can/
      "I can help you with:\n\n- **Blog posts** - Outlines, drafts, editing\n- **Emails** - Professional, cold outreach, follow-ups\n- **Code docs** - READMEs, inline comments, API docs\n- **Creative writing** - Stories, poetry, scripts\n- **Business** - Proposals, presentations, reports\n\nJust describe what you need!"
    else
      "That's an interesting topic! Here are some thoughts:\n\n1. Start with a clear objective\n2. Break it into manageable sections\n3. Use examples to illustrate key points\n4. End with actionable takeaways\n\nWould you like me to help you develop this further? Tell me more about what you're working on."
    end
  end
end
