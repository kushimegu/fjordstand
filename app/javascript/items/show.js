document.addEventListener('turbo:load', () => {
  const bigImage = document.getElementById('big-image');
  const thumbs = document.querySelectorAll('.thumbnail');
  let currentIndex = 0;
  thumbs.forEach(function (item, index) {
    item.addEventListener('click', function () {
      bigImage.src = this.dataset.image;
      currentIndex = index;
    });
  });
  document.getElementById('next').addEventListener('click', function () {
    currentIndex = (currentIndex + 1) % thumbs.length;
    bigImage.src = thumbs[currentIndex].dataset.image;
  });
  document.getElementById('prev').addEventListener('click', function () {
    currentIndex = (currentIndex - 1 + thumbs.length) % thumbs.length;
    bigImage.src = thumbs[currentIndex].dataset.image;
  });
});
