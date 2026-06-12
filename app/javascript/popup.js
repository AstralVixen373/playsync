const buttons = document.querySelectorAll("#button");
const confirm = document.getElementById("confirm");
const text = document.getElementById("text");

const temp = (code) => ({
  if (code = "Mark as finished") {
    const answer = document.getElementById("finishing");
    console.log(answer);
    return answer;
  }, elsif (code = "Leave match") {
    const answer = document.getElementById("leaving");
    console.log(answer);
    return answer;
  }, elsif (code = "Delete") {
    const answer = document.getElementById("deleting");
    console.log(answer);
    return answer;
  }
});

buttons.forEach((button) => {
  button.addEventListener("click", (event) => {
    event.preventDefault();
    text.replaceChildren();
    const content = button.innerText;
    const template = temp(content);
    text.insertAdjacentHTML("beforeend", `<p>Do you want to ${button.innerText}?</p>`);
    text.insertAdjacentHTML("beforeend", `<div class="d-flex justify-content-between gap-4">${template}<div>`);
    confirm.showModal();
  });
});
