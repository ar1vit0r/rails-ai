require "rails_helper"

RSpec.describe AiService do
  describe "#chat" do
    it "returns a response" do
      messages = [{ role: "user", content: "Hello" }]
      response = described_class.new.chat(messages)
      expect(response).to be_a(String)
      expect(response).not_to be_empty
    end
  end

  describe "#stream_chat" do
    it "yields chunks and returns full text" do
      messages = [{ role: "user", content: "Hello" }]
      chunks = []
      full_text = nil

      described_class.new.stream_chat(messages) do |chunk, text|
        chunks << chunk
        full_text = text
      end

      expect(chunks).not_to be_empty
      expect(full_text).to be_a(String)
      expect(full_text).not_to be_empty
    end

    it "builds complete text from chunks" do
      messages = [{ role: "user", content: "Write a blog post" }]
      collected = +""

      described_class.new.stream_chat(messages) do |_chunk, text|
        collected = text
      end

      expect(collected.split.length).to be > 1
    end
  end
end
