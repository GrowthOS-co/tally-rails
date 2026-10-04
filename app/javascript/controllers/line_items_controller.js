import { Controller } from "@hotwired/stimulus"

// Adds and removes line item rows in the invoice form. An invoice needs at
// least one line item, so the last row cannot be removed.
export default class extends Controller {
  static targets = [ "rows", "template", "row", "remove" ]

  add() {
    const html = this.templateTarget.innerHTML.replace(/NEW_ROW/g, Date.now().toString())
    this.rowsTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.target.closest("[data-line-items-target='row']").remove()
  }

  rowTargetConnected() {
    this.#toggleRemove()
  }

  rowTargetDisconnected() {
    this.#toggleRemove()
  }

  #toggleRemove() {
    const onlyOne = this.rowTargets.length === 1
    this.removeTargets.forEach((button) => button.disabled = onlyOne)
  }
}
