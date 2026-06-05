// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"
import "./game_search"


document.addEventListener("DOMContentLoaded", () => {
  const errorFlash = document.getElementById("error-notification");

  // On vérifie si la notification contient bien du texte (si une erreur existe)
  if (errorFlash && errorFlash.innerText.trim() !== "") {
    setTimeout(() => {
      // Effet de transition pour une disparition fluide
      errorFlash.style.transition = "opacity 0.5s ease";
      errorFlash.style.opacity = "0";

      // On retire complètement l'élément du DOM après l'effet
      setTimeout(() => {
        errorFlash.remove();
      }, 500);
    }, 5000); // 5000 ms = 5 secondes avant de commencer à disparaître
  }
});
