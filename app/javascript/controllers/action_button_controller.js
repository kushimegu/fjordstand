import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['button'];

  connect() {
    const params = new URLSearchParams(window.location.search);
    const target = params.get('target') || 'all';
    const targetButton = this.element.querySelector(`[data-target="${target}"]`);
    targetButton.classList.add('text-cyan-600', 'border-b-2', 'border-cyan-600');
  }

  toggle(event) {
    this.buttonTargets.forEach((btn) => {
      btn.classList.remove('text-cyan-600', 'border-b-2', 'border-cyan-600');
    });

    event.currentTarget.classList.add('text-cyan-600', 'border-b-2', 'border-cyan-600');
  }
}
