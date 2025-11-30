import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header"]

  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.handleScroll)
    this.handleScroll() // Check initial state
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  handleScroll() {
    const scrollY = window.scrollY || window.pageYOffset
    
    if (scrollY > 50) {
      this.headerTarget.classList.add("scrolled")
    } else {
      this.headerTarget.classList.remove("scrolled")
    }
  }
}

