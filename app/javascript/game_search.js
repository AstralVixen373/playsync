document.addEventListener("turbo:load", () => {
  const input = document.getElementById("game-search");
  const results = document.getElementById("game-results");
  const hiddenInput = document.getElementById("game-id");

  if (!input) return;

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
});
