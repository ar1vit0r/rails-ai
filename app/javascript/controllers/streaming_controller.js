import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  connect() {
    this.pendingMessages = []
    this.isStreaming = false
  }

  submit(event) {
    event.preventDefault()

    if (this.isStreaming) return

    const form = event.target
    const formData = new FormData(form)
    const content = formData.get("message[content]")

    if (!content.trim()) return

    this.inputTarget.value = ""
    this.submitTarget.disabled = true
    this.isStreaming = true

    fetch(form.action, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: formData
    }).then(() => {
      this.isStreaming = false
      this.submitTarget.disabled = false
    }).catch(() => {
      this.isStreaming = false
      this.submitTarget.disabled = false
    })
  }
}
