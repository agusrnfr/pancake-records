import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "audio",
    "button",
    "progressContainer",
    "progressBar",
    "currentTime",
    "duration"
  ]

  static values = {
    src: String,
    playingClass: { type: String, default: "is-playing" }
  }

  connect() {
    if (!this.hasAudioTarget || !this.srcValue) return

    this.audioTarget.src = this.srcValue
    this.audioTarget.addEventListener("timeupdate", () => this.updateProgress())
    this.audioTarget.addEventListener("loadedmetadata", () =>
      this.updateDuration()
    )
    this.audioTarget.addEventListener("ended", () => this.onEnded())
  }

  toggle() {
    if (!this.hasAudioTarget) return

    if (this.audioTarget.paused) {
      this.audioTarget.play()
      this.buttonTarget.classList.add(this.playingClassValue)
      this.buttonTarget.innerHTML = '<i class="fa-solid fa-pause"></i>'
    } else {
      this.audioTarget.pause()
      this.buttonTarget.classList.remove(this.playingClassValue)
      this.buttonTarget.innerHTML = '<i class="fa-solid fa-play"></i>'
    }
  }

  updateProgress() {
    if (!this.hasAudioTarget || !this.hasProgressBarTarget) return
    const audio = this.audioTarget
    if (!audio.duration || isNaN(audio.duration)) return

    const percent = (audio.currentTime / audio.duration) * 100
    this.progressBarTarget.style.width = `${percent}%`

    if (this.hasCurrentTimeTarget) {
      this.currentTimeTarget.textContent = this.formatTime(audio.currentTime)
    }
  }

  updateDuration() {
    if (!this.hasAudioTarget || !this.hasDurationTarget) return
    const audio = this.audioTarget
    if (!audio.duration || isNaN(audio.duration)) return
    this.durationTarget.textContent = this.formatTime(audio.duration)
  }

  seek(event) {
    if (!this.hasAudioTarget || !this.hasProgressContainerTarget) return
    const rect = this.progressContainerTarget.getBoundingClientRect()
    const clickX = event.clientX - rect.left
    const percent = clickX / rect.width

    const audio = this.audioTarget
    if (!audio.duration || isNaN(audio.duration)) return
    audio.currentTime = percent * audio.duration
  }

  onEnded() {
    if (!this.hasAudioTarget || !this.hasButtonTarget) return
    this.audioTarget.currentTime = 0
    this.buttonTarget.classList.remove(this.playingClassValue)
    this.buttonTarget.innerHTML = '<i class="fa-solid fa-play"></i>'
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = "0%"
    }
  }

  formatTime(seconds) {
    const secs = Math.floor(seconds || 0)
    const m = Math.floor(secs / 60)
    const s = secs % 60
    return `${m}:${s.toString().padStart(2, "0")}`
  }
}


