user = User.create!(
  email: "user@example.com",
  password: "password"
)

conversation = user.conversations.create!(title: "Welcome")
conversation.messages.create!(role: "system", content: "You are a helpful AI writing assistant.")
conversation.messages.create!(role: "user", content: "Hello! What can you help me with?")
conversation.messages.create!(role: "assistant", content: "I can help you write blog posts, emails, code documentation, and more. Just start a conversation and ask me anything!")

puts "Seeded user (user@example.com / password) with 1 conversation"
