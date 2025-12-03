import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "hiddenInput", "removeInput"]

  connect() {
    this.draggedElement = null
    this.syncHidden()
    this.syncRemoved()
  }

  itemTargetConnected(element) {
    element.addEventListener("dragstart", this.handleDragStart)
    element.addEventListener("dragover", this.handleDragOver)
    element.addEventListener("drop", this.handleDrop)
    element.addEventListener("dragend", this.handleDragEnd)
  }

  itemTargetDisconnected(element) {
    element.removeEventListener("dragstart", this.handleDragStart)
    element.removeEventListener("dragover", this.handleDragOver)
    element.removeEventListener("drop", this.handleDrop)
    element.removeEventListener("dragend", this.handleDragEnd)
  }

  handleDragStart = (event) => {
    this.draggedElement = event.currentTarget
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData(
      "text/plain",
      event.currentTarget.dataset.attachmentId
    )
    event.currentTarget.classList.add("is-dragging")
  }

  handleDragOver = (event) => {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"

    const target = event.currentTarget
    if (!this.draggedElement || target === this.draggedElement) return

    const rect = target.getBoundingClientRect()
    const offset = event.clientX - rect.left
    const halfway = rect.width / 2
    const parent = target.parentNode

    if (offset > halfway) {
      parent.insertBefore(this.draggedElement, target.nextSibling)
    } else {
      parent.insertBefore(this.draggedElement, target)
    }
  }

  handleDrop = (event) => {
    event.preventDefault()
    this.syncHidden()
  }

  handleDragEnd = () => {
    if (this.draggedElement) {
      this.draggedElement.classList.remove("is-dragging")
      this.draggedElement = null
    }
  }

  syncHidden() {
    if (!this.hasHiddenInputTarget) return
    const ids = this.itemTargets.map((el) => el.dataset.attachmentId)
    this.hiddenInputTarget.value = ids.join(",")
  }

  toggleRemove(event) {
    const button = event.currentTarget
    const item = button.closest("[data-attachment-id]")
    if (!item) return

    item.classList.toggle("is-marked-for-removal")
    this.syncRemoved()
  }

  syncRemoved() {
    if (!this.hasRemoveInputTarget) return
    const ids = this.itemTargets
      .filter((el) => el.classList.contains("is-marked-for-removal"))
      .map((el) => el.dataset.attachmentId)
    this.removeInputTarget.value = ids.join(",")
  }
}

