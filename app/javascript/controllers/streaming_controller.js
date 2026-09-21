import { Controller } from "@hotwired/stimulus"
import { cable } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["input", "submit", "thread", "count", "error"]
  static values = { conversationId: Number }

  async connect() {
    this.pendingMessages = []
    this.isStreaming = false
    this.online = false
    this.everConnected = false

    try {
      const subscription = await cable.subscribeTo(
        { channel: "ConversationChannel", conversation_id: this.conversationIdValue },
        {
          received: (data) => this.received(data),
          connected: () => this.subscriptionConnected(),
          disconnected: () => { this.online = false }
        }
      )
      // disconnect() may have run while the consumer was still loading
      if (this.element.isConnected) this.subscription = subscription
      else subscription.unsubscribe()
    } catch {
      // no live updates: submit() reloads the thread after each send instead
    }
  }

  disconnect() {
    this.subscription?.unsubscribe()
  }

  subscriptionConnected() {
    const reconnect = this.everConnected
    this.everConnected = true
    this.online = true
    // broadcasts sent while the socket was down are gone, so reload the thread from the database
    if (reconnect) this.resync()
  }

  // user_message and ai_chunk carry the rendered message; ai_start and ai_done have no html.
  received(data) {
    if (!data.html) return

    const nearBottom = window.innerHeight + window.scrollY >= document.documentElement.scrollHeight - 200
    const template = document.createElement("template")
    template.innerHTML = data.html.trim()
    const incoming = template.content.firstElementChild
    const existing = document.getElementById(incoming.id)

    if (existing) existing.replaceWith(incoming)
    else this.threadTarget.append(incoming)

    this.updateCount()
    if (nearBottom) incoming.scrollIntoView({ block: "nearest" })
  }

  async resync() {
    try {
      const response = await fetch(window.location.href, { headers: { Accept: "text/html" } })
      if (!response.ok) return

      const page = new DOMParser().parseFromString(await response.text(), "text/html")
      const fresh = page.getElementById("messages")
      if (!fresh) return

      this.threadTarget.replaceChildren(...fresh.children)
      this.updateCount()
    } catch {
      // offline: the next reconnect or send tries again
    }
  }

  updateCount() {
    const count = this.threadTarget.querySelectorAll(".msg").length
    this.countTarget.textContent = `${count} ${count === 1 ? "message" : "messages"}`
  }

  submit(event) {
    event.preventDefault()

    if (this.isStreaming) return

    const form = event.target
    const formData = new FormData(form)
    const content = formData.get("message[content]")

    if (!content.trim()) return

    this.inputTarget.value = ""
    this.errorTarget.hidden = true
    this.submitTarget.disabled = true
    this.isStreaming = true

    fetch(form.action, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: formData
    }).then(async (response) => {
      if (!response.ok) return this.fail(content)
      // the exchange is saved by now; if the socket wasn't up, its broadcasts were missed
      if (!this.online) await this.resync()
    }).catch(() => this.fail(content)).finally(() => {
      this.isStreaming = false
      this.submitTarget.disabled = false
    })
  }

  fail(content) {
    this.inputTarget.value = content
    this.errorTarget.hidden = false
  }
}
