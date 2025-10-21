/* ==========================================================
   THEME TOGGLE MODULE
   Cyclic theme switcher: Light → Sand → Dark → Light
   Persists user choice via localStorage
   ========================================================== */

(function() {
  const themes = ["theme-light", "theme-sand", "theme-dark"];
  const storageKey = "selectedTheme";

  // ---------- Apply stored theme on page load ----------
  function applyStoredTheme() {
    const saved = localStorage.getItem(storageKey);
    const body = document.body;
    const validTheme = themes.includes(saved) ? saved : "theme-light";

    // Remove any old theme class before applying
    themes.forEach(t => body.classList.remove(t));
    body.classList.add(validTheme);
  }

  // ---------- Cycle to the next theme ----------
  function toggleTheme() {
    const body = document.body;
    const current = themes.find(t => body.classList.contains(t)) || "theme-light";
    const next = themes[(themes.indexOf(current) + 1) % themes.length];

    themes.forEach(t => body.classList.remove(t));
    body.classList.add(next);
    localStorage.setItem(storageKey, next);
  }

  // ---------- Add toggle button behavior ----------
  function initThemeToggle() {
    applyStoredTheme();

    const btn = document.getElementById("themeToggle");
    if (!btn) return;

    btn.addEventListener("click", toggleTheme);
  }

  // Initialize once DOM is ready
  document.addEventListener("DOMContentLoaded", initThemeToggle);
})();
