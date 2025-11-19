import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form"];

  connect() {
    this.timeout = null;
  }

  changed() {
    const pageInput = this.formTarget.querySelector('input[name="page"]');
    if (pageInput) pageInput.value = '1';

    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit();
    }, 300);
  }
}
