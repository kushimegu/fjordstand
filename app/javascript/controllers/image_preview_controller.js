import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ['input', 'preview', 'extraContainer'];

  connect() {
    this.updateExtraSlots();
  }

  removeImage(e) {
    const button = e.currentTarget;
    const hiddenId = button.dataset.target;
    const hiddenField = document.getElementById(hiddenId);
    if (hiddenField) {
      hiddenField.remove();
    }

    const preview = button.closest("[data-image-preview-target='savedPreview']");
    if (preview) {
      preview.remove();
      this.updateExtraSlots();
    }
  }

  previewSingleImage(e) {
    const file = e.target.files[0];
    const container = e.target.closest('label').querySelector('[data-image-preview-target="container"]');
    const img = container.querySelector('img');
    const span = container.querySelector('span');

    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        img.src = event.target.result;
        img.classList.remove('hidden');
        span.classList.add('hidden');
        container.classList.remove('border-dashed', 'border-2');
        container.classList.add('border');
      };
      reader.readAsDataURL(file);
    }
  }

  previewMultipleImages(e) {
    const files = Array.from(e.target.files).slice(0, 5);
    const mobileContainer = e.target.closest('label').querySelector('[data-image-preview-target="mobileContainer"]');
    const span = mobileContainer.querySelector('span');
    const label = e.target.closest('label');

    const readAndPreview = files.map((file) => {
      return new Promise((resolve) => {
        const reader = new FileReader();
        reader.onload = (e) => resolve(e.target.result);
        reader.readAsDataURL(file);
      });
    });

    Promise.all(readAndPreview).then((results) => {
      results.forEach((src) => {
        const wrapper = document.createElement('div');
        wrapper.className = 'h-20 w-full flex items-center justify-center';

        const border = document.createElement('div');
        border.className = 'aspect-square h-20 border border-2 rounded border-gray-200 flex items-center justify-center';
        wrapper.appendChild(border);

        const img = document.createElement('img');
        img.src = src;
        img.className = 'w-full h-full object-contain';

        border.appendChild(img);
        mobileContainer.appendChild(wrapper);
      });
    });
    span.classList.add('hidden');
    label.classList.remove('flex-1');
    mobileContainer.classList.remove('border-dashed', 'bg-gray-50', 'border-2', 'border-gray-200', 'flex', 'flex-wrap', 'items-center', 'justify-start');
    mobileContainer.classList.add('grid', 'grid-cols-3', 'gap-2', 'sm:grid-cols-5');
  }

  previewUploadedImages() {
    if (!this.hasPreviewTarget) return;

    const files = Array.from(this.inputTarget.files).slice(0, 5);

    const readAndPreview = files.map((file) => {
      return new Promise((resolve) => {
        const reader = new FileReader();
        reader.onload = (e) => resolve(e.target.result);
        reader.readAsDataURL(file);
      });
    });

    Promise.all(readAndPreview).then((results) => {
      results.forEach((src) => {
        const wrapper = document.createElement('div');
        wrapper.className = 'aspect-square h-25 relative flex items-center justify-center border-gray-200 rounded-lg overflow-hidden bg-gray-50';

        const img = document.createElement('img');
        img.src = src;
        img.className = 'w-full h-full object-contain relative';

        wrapper.appendChild(img);
        this.previewTarget.appendChild(wrapper);
      });
    });
  }

  updateExtraSlots() {
    const currentImageCount = this.element.querySelectorAll('[data-image-preview-target="savedPreview"]').length;
    const remainingSlots = 5 - currentImageCount;
    this.extraContainerTargets.forEach((slot, index) => {
      if (index < remainingSlots) {
        slot.classList.remove('sm:hidden');
        slot.classList.add('sm:block');
      } else {
        slot.classList.add('sm:hidden');
        slot.classList.remove('sm:block');
      }
    });
  }
}
