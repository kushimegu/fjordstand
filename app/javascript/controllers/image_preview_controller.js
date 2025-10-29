import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ['input', 'preview'];

  previewImage() {
    const files = this.inputTarget.files;
    this.previewTarget.innerHTML = '';

    Array.from(files).forEach((file) => {
      const reader = new FileReader();
      reader.onload = (e) => {
        const wrapper = document.createElement('div');
        wrapper.className = 'aspect-square h-25 flex items-center justify-center bg-gray-100';

        const img = document.createElement('img');
        img.src = e.target.result;
        img.className = 'object-contain w-full h-full';

        wrapper.appendChild(img);
        this.previewTarget.appendChild(wrapper);
      };
      reader.readAsDataURL(file);
    });
  }
}
