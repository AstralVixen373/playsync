const buttons = document.querySelectorAll("#button");
const confirm = document.getElementById("confirm");
const text = document.getElementById("text");

const temp = (button) => ({
  if (button = "Mark as finished") {
    console.log(document.getElementById("finishing"));
    return document.getElementById("finishing").innerHTML;
  }, elsif (button = "Leave match") {
    return document.getElementById("leaving").innerHTML;
  }, elsif (button = "Delete") {
    return document.getElementById("deleting").innerHTML;
  }
});

buttons.forEach((button) => {
  button.addEventListener("click", (event) => {
    event.preventDefault();
    text.replaceChildren();
    const template = temp(button.innerText);
    text.insertAdjacentHTML("beforeend", `<img src="app/assets/images/playsync-logo.png" alt="PlaySync logo">`);
    text.insertAdjacentHTML("beforeend", `<h1>PlaySync indicates :</h1>`);
    text.insertAdjacentHTML("beforeend", `<p>Do you want to ${button.innerText}?</p>`);
    text.insertAdjacentHTML("beforeend", `${template}`);
    confirm.showModal();
  });
});
