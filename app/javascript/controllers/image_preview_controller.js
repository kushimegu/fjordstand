import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ['input', 'preview'];

  removeImage(e) {
    const button = e.currentTarget;
    const hiddenId = button.dataset.target;
    const hiddenField = document.getElementById(hiddenId);
    if (hiddenField) hiddenField.remove();
    const preview = button.closest("[data-image-preview-target='saved-preview']");
    if (preview) preview.remove();
  }

  previewImage() {
    const files = Array.from(this.inputTarget.files);
    this.previewTarget.innerHTML = '';

    const previews = [];

    files.forEach((file, index) => {
      const reader = new FileReader();
      reader.onload = (e) => {
        previews[index] = e.target.result;

        if (previews.filter(Boolean).length === files.length) {
          previews.forEach((preview) => {
            const wrapper = document.createElement('div');
            wrapper.className = 'aspect-square h-25 flex items-center justify-center bg-gray-100';

            const img = document.createElement('img');
            img.src = preview;
            img.className = 'object-contain w-full h-full';

            wrapper.appendChild(img);
            this.previewTarget.appendChild(wrapper);
          });
        }
      };
      reader.readAsDataURL(file);
    });
  }
}
