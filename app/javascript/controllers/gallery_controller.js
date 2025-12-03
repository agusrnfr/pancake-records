import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mainImage", "thumbnail"]
  static values = {
    activeClass: { type: String, default: "active" },
    index: { type: Number, default: 0 }
  }

  connect() {
    if (this.indexValue < 0) this.indexValue = 0
    this.#updateFromIndex()
  }

  change(event) {
    const thumb = event.currentTarget
    const index = this.thumbnailTargets.indexOf(thumb)
    if (index === -1) return

    this.indexValue = index
    this.#updateFromIndex()
  }

  next() {
    if (this.thumbnailTargets.length === 0) return
    this.indexValue = (this.indexValue + 1) % this.thumbnailTargets.length
    this.#updateFromIndex()
  }

  previous() {
    if (this.thumbnailTargets.length === 0) return
    this.indexValue =
      (this.indexValue - 1 + this.thumbnailTargets.length) %
      this.thumbnailTargets.length
    this.#updateFromIndex()
  }

  #updateFromIndex() {
    if (!this.hasMainImageTarget || this.thumbnailTargets.length === 0) return

    const currentThumb = this.thumbnailTargets[this.indexValue]
    const url = currentThumb?.dataset.galleryImageUrlValue
    if (!url) return

    this.mainImageTarget.src = url

    this.thumbnailTargets.forEach((el, i) => {
      if (i === this.indexValue) {
        el.classList.add(this.activeClassValue)
      } else {
        el.classList.remove(this.activeClassValue)
      }
    })
  }
}

