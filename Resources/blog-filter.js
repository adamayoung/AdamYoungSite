(() => {
  const list = document.querySelector('[data-blog-list]');
  const empty = document.querySelector('[data-blog-empty]');
  const input = document.getElementById('topbar-search');
  const form = input?.closest('form');
  if (!list || !input) return;

  const rows = Array.from(list.querySelectorAll('.post-row'));

  const apply = (raw) => {
    const q = (raw || '').trim().toLowerCase();
    let visible = 0;
    for (const row of rows) {
      const haystack = [
        row.dataset.title || '',
        row.dataset.description || '',
        row.dataset.tags || ''
      ].join(' ');
      const match = q === '' || haystack.includes(q);
      row.classList.toggle('hidden', !match);
      if (match) visible++;
    }
    if (empty) empty.classList.toggle('hidden', visible !== 0);
  };

  const initial = new URLSearchParams(window.location.search);
  const presetQ = initial.get('q') || '';
  const presetTag = initial.get('tag') || '';
  const seed = presetQ || presetTag;
  if (seed) {
    input.value = seed;
    apply(seed);
  }

  input.addEventListener('input', (e) => apply(e.target.value));
  form?.addEventListener('submit', (e) => {
    e.preventDefault();
    apply(input.value);
  });
})();
