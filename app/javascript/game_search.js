document.addEventListener("turbo:load", () => {
  // --- Create / edit a post: single game selection -------------------------
  const input = document.getElementById("game-search");
  const results = document.getElementById("game-results");
  const hiddenInput = document.getElementById("game-id");

  if (input) {
    input.addEventListener("input", async () => {
      const query = input.value;

      if (query.length < 2) {
        results.innerHTML = "";
        return;
      }

      const response = await fetch(`/games/search?q=${query}`);
      const games = await response.json();

      results.innerHTML = "";

      games.forEach(game => {
        const item = document.createElement("div");

        item.textContent = game.name;
        item.style.cursor = "pointer";
        item.style.padding = "8px";

        item.addEventListener("click", () => {
          input.value = game.name;
          hiddenInput.value = game.id;
          results.innerHTML = "";
        });

        results.appendChild(item);
      });
    });
  }

  // --- Reusable multi game picker (chips) ----------------------------------
  // Used on the search page (auto-submits the filter form) and on the profile
  // preferences form (no auto-submit — saved on form submit).
  const initGameMulti = (prefix, { autoSubmit } = {}) => {
    const searchInput = document.getElementById(`${prefix}-game-search`);
    const searchResults = document.getElementById(`${prefix}-game-results`);
    const chips = document.getElementById(`${prefix}-game-chips`);
    if (!searchInput || !chips) return;

    const form = searchInput.closest("form");
    const maybeSubmit = () => { if (autoSubmit && form) form.requestSubmit(); };

    const hasGame = (id) =>
      chips.querySelector(`input[name="${chips.dataset.field}"][value="${id}"]`) !== null;

    const addChip = (game) => {
      if (hasGame(game.id)) return;

      const chip = document.createElement("span");
      chip.className = "game-chip";
      chip.style.cssText =
        "display: inline-flex; align-items: center; gap: 0.3rem; background: #eef; border-radius: 12px; padding: 0.15rem 0.6rem; font-size: 0.85rem;";

      const hidden = document.createElement("input");
      hidden.type = "hidden";
      hidden.name = chips.dataset.field;
      hidden.value = game.id;

      const label = document.createElement("span");
      label.textContent = game.name;

      const remove = document.createElement("button");
      remove.type = "button";
      remove.className = "game-chip-remove";
      remove.textContent = "×";
      remove.style.cssText =
        "border: none; background: none; cursor: pointer; font-weight: bold;";

      chip.append(hidden, label, remove);
      chips.appendChild(chip);
    };

    searchInput.addEventListener("input", async () => {
      const query = searchInput.value;

      if (query.length < 2) {
        searchResults.innerHTML = "";
        return;
      }

      const response = await fetch(`/games/search?q=${query}`);
      const games = await response.json();

      searchResults.innerHTML = "";

      games.forEach(game => {
        const item = document.createElement("div");
        item.textContent = game.name;
        item.style.cursor = "pointer";
        item.style.padding = "8px";

        item.addEventListener("click", () => {
          addChip(game);
          searchInput.value = "";
          searchResults.innerHTML = "";
          maybeSubmit();
        });

        searchResults.appendChild(item);
      });
    });

    chips.addEventListener("click", (event) => {
      if (!event.target.classList.contains("game-chip-remove")) return;

      // Server-rendered chips use `.ps-game-chip`; JS-added ones use `.game-chip`.
      const chip = event.target.closest(".game-chip, .ps-game-chip");
      if (!chip) return;

      chip.remove();
      maybeSubmit();
    });
  };

  initGameMulti("filter", { autoSubmit: true });
  initGameMulti("profile", { autoSubmit: false });
});
