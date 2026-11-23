import { Controller } from "@hotwired/stimulus"

// Keeps the Approve button disabled until the reviewer has entered a name
// and the fix steps are not empty, and shows a running character count.
export default class extends Controller {
  static targets = ["text", "reviewer", "approve", "counter"]

  declare readonly textTarget: HTMLTextAreaElement
  declare readonly reviewerTarget: HTMLInputElement
  declare readonly approveTarget: HTMLInputElement
  declare readonly counterTarget: HTMLElement
  declare readonly hasCounterTarget: boolean

  connect(): void {
    this.update()
  }

  update(): void {
    const text = this.textTarget.value.trim()
    const reviewer = this.reviewerTarget.value.trim()

    this.approveTarget.disabled = text.length === 0 || reviewer.length === 0

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${text.length} characters`
    }
  }
}
