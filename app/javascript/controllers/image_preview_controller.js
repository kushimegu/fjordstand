import { Controller } from '@hotwired/stimulus';

// Connects to data-controller="image-preview"
export default class extends Controller {
  static targets = ['input', 'preview', 'savedPreview', 'extraContainer', 'multipleContainer'];

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
    const label = button.closest('label');
    const hasInput = label && label.querySelector('input[type="file"]');
    if (preview && !hasInput) {
      preview.remove();
    } else if (label) {
      const img = label.querySelector('img');
      const span = label.querySelector('span');
      const input = label.querySelector('input[type="file"]');

      if (img) { img.src = ''; img.classList.add('hidden'); }
      if (span) span.classList.remove('hidden');

      if (input) {
        input.value = ''; 
      }

      label.dataset.imagePreviewTarget = 'extraContainer';
      const container = label.querySelector('[data-image-preview-target="container"]');
      if (container) {
        container.className = "aspect-square w-full border-2 border-dashed border-gray-200 bg-gray-50 rounded hover:border-gray-400 flex items-center justify-center overflow-hidden";
      }

      button.remove();
    }

    this.updateExtraSlots();
  }

  previewMultipleImages(e) {
    const files = Array.from(e.target.files).slice(0, 5);
    this.element.querySelectorAll('.js-multiple-preview').forEach((element) => element.remove());

    const readAndPreview = files.map((file) => {
      return new Promise((resolve) => {
        const reader = new FileReader();
        reader.onload = (event) => resolve(event.target.result);
        reader.readAsDataURL(file);
      });
    });

    Promise.all(readAndPreview).then((results) => {
      results.forEach((src) => {
        const wrapper = document.createElement('div');
        wrapper.className = 'rounded-lg overflow-hidden flex items-center justify-center';
        wrapper.dataset.imagePreviewTarget = 'savedPreview';
        wrapper.classList.add('js-multiple-preview');

        const div = document.createElement('div');
        div.className = 'relative aspect-square rounded-lg border border-gray-200 bg-gray-100';
        div.innerHTML = `
          <img src="${src}" class="w-full h-full object-contain">
          <button type="button" data-action="click->image-preview#removeImage" class="cursor-pointer absolute top-0 right-0 text-gray-600 hover:text-red-400 bg-white/70 rounded-full hover:bg-white">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
              <path stroke-linecap="round" stroke-linejoin="round" d="m9.75 9.75 4.5 4.5m0-4.5-4.5 4.5M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
            </svg>
          </button>
        `;
        wrapper.appendChild(div);
        this.previewTarget.insertBefore(wrapper, this.extraContainerTargets[0]);

        this.updateExtraSlots();
      });
    });
  }

  previewSingleImage(e) {
    const file = e.target.files[0];
    const label = e.target.closest('label')
    const container = label.querySelector('[data-image-preview-target="container"]');
    const img = container.querySelector('img');
    const span = container.querySelector('span');

    if (file) {
      label.dataset.imagePreviewTarget = 'savedPreview';

      const reader = new FileReader();
      reader.onload = (event) => {
        img.src = event.target.result;
        img.classList.remove('hidden');
        span.classList.add('hidden');
        container.classList.remove('border-dashed', 'p-6');
        container.classList.add('border');

        if (!container.querySelector('button')) {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.dataset.action = 'click->image-preview#removeImage';
        btn.className = 'cursor-pointer absolute top-0 right-0 text-gray-600 hover:text-red-400 bg-white/70 rounded-full hover:bg-white';
        btn.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
          <path stroke-linecap="round" stroke-linejoin="round" d="m9.75 9.75 4.5 4.5m0-4.5-4.5 4.5M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
        </svg>
        `;
        container.classList.add('relative');
        container.appendChild(btn);
        }

        this.updateExtraSlots();
      };
      reader.readAsDataURL(file);
    }
  }

  updateExtraSlots() {
    const filledCount = this.element.querySelectorAll('[data-image-preview-target="savedPreview"]').length;
    const remainingCount = 5 - filledCount;

    const emptySlots = this.extraContainerTargets.filter((slot) => slot.dataset.imagePreviewTarget === 'extraContainer');
    this.extraContainerTargets.forEach((slot) => {
      if (slot.dataset.imagePreviewTarget === 'savedPreview') {
        slot.classList.remove('hidden');
      }
    });
    emptySlots.forEach((slot, index) => {
      if (index < remainingCount) {
        slot.classList.remove('hidden');
      } else {
        slot.classList.add('hidden');
      }
    });
  }
}
