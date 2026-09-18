# Rails AI Writer

A chat-style AI writing assistant built with Rails 8, streaming responses token by token over Action Cable.

**[Live Demo](https://rails-ai.onrender.com)** (free Render tier: the first request after idle can take about a minute to wake up; sign in or register to start a conversation)

## Highlights

- **Streaming responses**: the assistant's reply appears chunk by chunk via Action Cable, no page reload
- **Conversations**: per-user conversation history, each with its own message thread
- **Devise auth**: every conversation is scoped to the signed-in user
- **Mock mode**: with no `OPENAI_API_KEY` set, `AiService` streams a canned response, so the app runs end to end without an API account

## How streaming works

`MessagesController#create` saves the user message, then streams the assistant reply on the `conversation_<id>` channel (`ConversationChannel`) as four event types:

| Event | Meaning |
|-------|---------|
| `user_message` | rendered HTML of the message the user just sent |
| `ai_start` | placeholder assistant message created (carries its `message_id`) |
| `ai_chunk` | latest rendered HTML of the assistant message as text arrives |
| `ai_done` | stream finished, final text persisted |

The cable adapter is `async` in development and `solid_cable` (database-backed) in production.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Ruby on Rails 8.1, Ruby 3.4 |
| Realtime | Action Cable (`solid_cable` in production) |
| Auth | Devise |
| AI | `openai` gem, `gpt-4o-mini` |
| Frontend | Turbo, Stimulus, Tailwind CSS |
| Background/cache | Solid Queue, Solid Cache |
| Testing | RSpec |
| Deploy | Docker + Render |

## Quick Start

```bash
git clone https://github.com/ar1vit0r/rails-ai.git
cd rails-ai
bundle install
bin/rails db:prepare
bin/dev
```

To use the real model instead of mock mode, export a key before starting:

```bash
export OPENAI_API_KEY=your-key
```

## Testing

```bash
bundle exec rspec
```

## Deployment

Configured via `render.yaml` (Render Blueprints). Environment variables:

| Variable | Purpose |
|----------|---------|
| `RAILS_MASTER_KEY` | decrypts Rails credentials (set manually in Render) |
| `OPENAI_API_KEY` | enables the real model; omit to run in mock mode |
| `DATABASE_URL` | provisioned from the `rails-ai-db` database in `render.yaml` |
