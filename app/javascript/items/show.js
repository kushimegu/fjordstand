document.addEventListener('turbo:load', () => {
  const thumbs = document.querySelectorAll('.thumbnail');
  thumbs.forEach(function (item) {
    item.addEventListener('click', function () {
      document.getElementById('big-image').src = this.dataset.image;
    });
  });
});
