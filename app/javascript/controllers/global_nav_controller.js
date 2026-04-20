import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['button'];

  connect() {
    const path = window.location.pathname;
    let target = null;
    if (path === '/items') {
      target = 'items';
    } else if (path === '/watches') {
      target = 'watches';
    } else if (path === '/listings') {
      target = 'listings';
    } else if (path === '/entries') {
      target = 'entries';
    } else if (path === '/transactions') {
      target = 'transactions';
    }
    if (target) {
      const targetButton = this.element.querySelector(`[data-target="${target}"]`);
      targetButton.classList.add('active-tab', 'text-gray-700', 'bg-gray-100');
    }
  }

  toggle(event) {
    this.buttonTargets.forEach((btn) => {
      btn.classList.remove('active-tab', 'text-gray-700', 'bg-gray-100');
    });

    event.currentTarget.classList.add('active-tab', 'text-gray-700', 'bg-gray-100');
  }
}
