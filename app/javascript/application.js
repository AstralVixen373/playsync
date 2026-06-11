// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"

import "controllers"
import "@popperjs/core"
import "bootstrap"
import "./game_search"
import "./popup"


// Auto-dismiss the bottom-right flash popups (and form-error blocks) after 3s.
// `turbo:load` fires on the initial load and after every Turbo navigation, so
// flash messages set on redirects are caught too.
const FLASH_DISMISS_DELAY = 3000;

function autoDismissFlash() {
  document.querySelectorAll(".alert, #error-notification").forEach((popup) => {
    if (popup.innerText.trim() === "") return;

    setTimeout(() => {
      popup.style.transition = "opacity 0.5s ease";
      popup.style.opacity = "0";
      setTimeout(() => popup.remove(), 500);
    }, FLASH_DISMISS_DELAY);
  });
}

document.addEventListener("turbo:load", autoDismissFlash);
