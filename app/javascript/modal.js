const modal = document.querySelector(".modal");
const finish = document.getElementById("finished");
const confirm = document.getElementById("confirm");
console.log(modal);
console.log(finish);
console.log(confirm);

finish.addEventListener("click", (event) => {
  event.preventDefault();
  modal.focus();
  confirm.addEventListener("click", (event) => {
    
  });
});
