import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['button'];

  connect() {
    this.buttonTargets.forEach((button) => {
      if (button.textContent.trim() === '全て') {
        button.classList.add('text-cyan-600', 'border-b-2', 'border-cyan-600');
      }
    });
  }

  toggle(event) {
    this.buttonTargets.forEach((btn) => {
      btn.classList.remove('text-cyan-600', 'border-b-2', 'border-cyan-600');
    });

    event.currentTarget.classList.add('text-cyan-600', 'border-b-2', 'border-cyan-600');
  }
}
