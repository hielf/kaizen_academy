import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    // Add form validation on submit
    if (this.hasFormTarget) {
      this.formTarget.addEventListener('submit', this.validateForm.bind(this))
    }
  }

  formatCardNumber(event) {
    let value = event.target.value.replace(/\D/g, '') // Remove non-digits
    value = value.replace(/(.{4})/g, '$1 ').trim() // Add space every 4 digits
    event.target.value = value
  }

  formatExpiryDate(event) {
    let value = event.target.value.replace(/\D/g, '') // Remove non-digits
    
    if (value.length >= 2) {
      const month = value.substring(0, 2)
      const year = value.substring(2, 4)
      
      // Validate month (01-12)
      if (parseInt(month) > 12) {
        value = '12' + value.substring(2)
      } else if (parseInt(month) < 1) {
        value = '01' + value.substring(2)
      }
      
      // Format as MM/YY
      if (value.length >= 2) {
        value = value.substring(0, 2) + '/' + value.substring(2, 4)
      }
    }
    
    event.target.value = value
  }

  formatCVV(event) {
    let value = event.target.value.replace(/\D/g, '') // Remove non-digits
    event.target.value = value
  }

  validateCardNumber(event) {
    // TEMPORARILY DISABLED - Allow any card number
    // const value = event.target.value.replace(/\s/g, '')
    // const isValid = this.luhnCheck(value)
    
    // if (value.length > 0 && !isValid) {
    //   event.target.classList.add('border-red-500')
    //   event.target.classList.remove('border-gray-300')
    //   this.showError(event.target, 'Invalid card number')
    // } else {
    //   event.target.classList.remove('border-red-500')
    //   event.target.classList.add('border-gray-300')
    //   this.hideError(event.target)
    // }
    
    // Clear any existing errors
    event.target.classList.remove('border-red-500')
    event.target.classList.add('border-gray-300')
    this.hideError(event.target)
  }

  validateExpiryDate(event) {
    const value = event.target.value
    const isValid = /^(0[1-9]|1[0-2])\/\d{2}$/.test(value)
    
    if (value.length > 0 && !isValid) {
      event.target.classList.add('border-red-500')
      event.target.classList.remove('border-gray-300')
      this.showError(event.target, 'Invalid expiry date (MM/YY)')
    } else {
      event.target.classList.remove('border-red-500')
      event.target.classList.add('border-gray-300')
      this.hideError(event.target)
    }
  }

  validateCVV(event) {
    const value = event.target.value
    const isValid = /^\d{3,4}$/.test(value)
    
    if (value.length > 0 && !isValid) {
      event.target.classList.add('border-red-500')
      event.target.classList.remove('border-gray-300')
      this.showError(event.target, 'Invalid CVV (3-4 digits)')
    } else {
      event.target.classList.remove('border-red-500')
      event.target.classList.add('border-gray-300')
      this.hideError(event.target)
    }
  }

  validateForm(event) {
    const cardNumber = this.element.querySelector('input[name*="card_number"]')
    const expiryDate = this.element.querySelector('input[name*="expiry_date"]')
    const cvv = this.element.querySelector('input[name*="cvv"]')
    
    let isValid = true
    
    // TEMPORARILY DISABLED - Skip card number validation
    // // Validate card number
    // if (cardNumber) {
    //   const cardValue = cardNumber.value.replace(/\s/g, '')
    //   if (!this.luhnCheck(cardValue)) {
    //     this.showError(cardNumber, 'Invalid card number')
    //     isValid = false
    //   }
    // }
    
    // Validate expiry date
    if (expiryDate) {
      const expiryValue = expiryDate.value
      if (!/^(0[1-9]|1[0-2])\/\d{2}$/.test(expiryValue)) {
        this.showError(expiryDate, 'Invalid expiry date (MM/YY)')
        isValid = false
      }
    }
    
    // Validate CVV
    if (cvv) {
      const cvvValue = cvv.value
      if (!/^\d{3,4}$/.test(cvvValue)) {
        this.showError(cvv, 'Invalid CVV (3-4 digits)')
        isValid = false
      }
    }
    
    if (!isValid) {
      event.preventDefault()
      return false
    }
    
    return true
  }

  showError(field, message) {
    // Remove existing error message
    this.hideError(field)
    
    // Create error message element
    const errorDiv = document.createElement('div')
    errorDiv.className = 'text-red-500 text-xs mt-1'
    errorDiv.textContent = message
    errorDiv.setAttribute('data-error-for', field.name)
    
    // Insert after the field
    field.parentNode.appendChild(errorDiv)
  }

  hideError(field) {
    // Find error message by data attribute instead of ID
    const errorDiv = field.parentNode.querySelector(`[data-error-for="${field.name}"]`)
    if (errorDiv) {
      errorDiv.remove()
    }
  }

  // Luhn algorithm for card number validation
  luhnCheck(value) {
    if (value.length < 13 || value.length > 19) return false
    
    let sum = 0
    let isEven = false
    
    // Loop through values starting from the rightmost side
    for (let i = value.length - 1; i >= 0; i--) {
      let digit = parseInt(value.charAt(i))
      
      if (isEven) {
        digit *= 2
        if (digit > 9) {
          digit -= 9
        }
      }
      
      sum += digit
      isEven = !isEven
    }
    
    return (sum % 10) === 0
  }
} 