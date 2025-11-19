import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['bigImage', 'thumbnail'];

  connect() {
    this.currentIndex = 0;
  }

  show(e) {
    const thumb = e.currentTarget;
    this.bigImageTarget.src = thumb.dataset.image;
    this.currentIndex = this.thumbnailTargets.indexOf(thumb);
  }

  next() {
    this.currentIndex = (this.currentIndex + 1) % this.thumbnailTargets.length;
    this.bigImageTarget.src = this.thumbnailTargets[this.currentIndex].dataset.image;
  }

  prev() {
    this.currentIndex = (this.currentIndex - 1 + this.thumbnailTargets.length) % this.thumbnailTargets.length;
    this.bigImageTarget.src = this.thumbnailTargets[this.currentIndex].dataset.image;
  }
}
