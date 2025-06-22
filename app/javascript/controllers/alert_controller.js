import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    autoDismiss: { type: Boolean, default: true },
    duration: { type: Number, default: 5000 }
  }

  connect() {
    // Animate in
    this.element.classList.remove('opacity-0', 'translate-y-[-10px]')
    this.element.classList.add('opacity-100', 'translate-y-0')

    // Auto-dismiss functionality
    if (this.autoDismissValue) {
      this.dismissTimer = setTimeout(() => {
        this.dismiss()
      }, this.durationValue)
    }

    // Pause auto-dismiss on hover/focus
    this.element.addEventListener('mouseenter', this.pauseTimer.bind(this))
    this.element.addEventListener('focusin', this.pauseTimer.bind(this))
    this.element.addEventListener('mouseleave', this.resumeTimer.bind(this))
    this.element.addEventListener('focusout', this.resumeTimer.bind(this))
  }

  disconnect() {
    if (this.dismissTimer) {
      clearTimeout(this.dismissTimer)
    }
    if (this.resumeTimer) {
      clearTimeout(this.resumeTimer)
    }
  }

  dismiss() {
    // Animate out
    this.element.classList.add('opacity-0', 'translate-y-[-10px]')
    
    // Remove from DOM after animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  pauseTimer() {
    if (this.dismissTimer) {
      clearTimeout(this.dismissTimer)
      this.dismissTimer = null
    }
  }

  resumeTimer() {
    if (this.autoDismissValue && !this.dismissTimer) {
      this.dismissTimer = setTimeout(() => {
        this.dismiss()
      }, this.durationValue)
    }
  }
} 