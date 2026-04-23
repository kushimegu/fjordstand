import { Controller } from '@hotwired/stimulus';

const ACTIVE = ['active-tab', 'bg-white', 'text-gray-900', 'font-semibold', 'shadow-sm'];
const INACTIVE = ['text-gray-500'];

export default class extends Controller {
  static targets = ['button'];

  connect() {
    const params = new URLSearchParams(window.location.search);
    const target = params.get('status') || 'all';
    const targetButton = this.element.querySelector(`[data-target="${target}"]`);
    if (targetButton) {
      this.buttonTargets.forEach((btn) => this.setInactive(btn));
      this.setActive(targetButton);
    }
  }

  toggle(event) {
    this.buttonTargets.forEach((btn) => this.setInactive(btn));
    this.setActive(event.currentTarget);
  }

  setActive(btn) {
    btn.classList.remove(...INACTIVE);
    btn.classList.add(...ACTIVE);
  }

  setInactive(btn) {
    btn.classList.remove(...ACTIVE);
    btn.classList.add(...INACTIVE);
  }
}
