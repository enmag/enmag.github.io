// Behaviour shared by every page. Each block is a no-op on pages that do not
// contain the elements it drives, so all pages load the same file.

// Mobile navigation.
(function () {
  const toggle = document.getElementById('nav-toggle');
  const menu = document.getElementById('nav-mobile');
  const links = document.querySelector('.nav-links');
  if (!toggle || !menu || !links) return;

  function close() {
    menu.classList.remove('open');
    toggle.setAttribute('aria-expanded', 'false');
  }

  // The menu offers exactly the destinations of the bar, so it is cloned from
  // it rather than kept as a second list in the markup.
  links.querySelectorAll('a').forEach(function (link) {
    const item = link.cloneNode(true);
    item.addEventListener('click', close);
    menu.appendChild(item);
  });

  toggle.addEventListener('click', function () {
    const open = menu.classList.toggle('open');
    toggle.setAttribute('aria-expanded', String(open));
  });

  // Collapse once the bar itself is back: same 62rem breakpoint as the
  // stylesheet, in pixels.
  window.addEventListener('resize', function () {
    if (window.innerWidth > 992) close();
  });
})();

// Publication abstracts. A card toggles its own abstract; the Abstract chip
// stays the labelled control for keyboard and screen readers, and its click
// bubbles up to the same handler, so there is only one code path.
(function () {
  document.querySelectorAll('.pub').forEach(function (card) {
    const panel = card.querySelector('.pub-abstract');
    const btn = card.querySelector('button.chip');
    if (!panel) return;

    card.addEventListener('click', function (event) {
      if (event.target.closest('a')) return;

      // Releasing the mouse after selecting text is not a toggle.
      const selection = window.getSelection();
      if (selection && String(selection).length) return;

      const opening = panel.hasAttribute('hidden');
      panel.toggleAttribute('hidden', !opening);
     if (btn) {
	btn.setAttribute('aria-expanded', String(opening));
	btn.classList.toggle('chip-active', opening);
      }
    });
  });
})();
