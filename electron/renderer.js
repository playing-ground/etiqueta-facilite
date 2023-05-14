const productList = document.getElementById("product-list");
const counter = document.getElementById("counter");

const setButton = document.getElementById("btn");
const titleInput = document.getElementById("title");

const btn = document.getElementById("btn2");
const filePathElement = document.getElementById("filePath");

const initialDateElement = document.getElementById("initial-date");
const finalDateElement = document.getElementById("final-date");

/* window.electronAPI.onSqlQuery((_event, value) => {
  productList.innerHTML = "";
  console.log(value);
  value.map((product) => {
    const item = document.createElement("li");
    item.innerText = product.PRO_DESCRICAO;
    productList.appendChild(item);
  });
}); */ 1;

const dateForm = document.getElementById("date-form");
const period = document.getElementById("period");

const statusLabel = document.getElementById("status");

let date = new Date();

date.setDate(0);
date.setDate(1);
const firstDay = new Date(date).toLocaleDateString("en-CA");

date = new Date();
const lastDay = new Date(date.setMonth(date.getMonth(), 0)).toLocaleDateString(
  "en-CA"
);

initialDateElement.value = firstDay;
finalDateElement.value = lastDay;

dateForm.addEventListener("submit", handleFormSubmit);

async function handleFormSubmit(event) {
  event.preventDefault();

  await window.electronAPI.openQuery({
    firstDay: initialDateElement.value,
    lastDay: finalDateElement.value,
  });

  statusLabel.innerText = "Concluído";
  setTimeout(() => {
    window.electronAPI.onRequestClose();
  }, 1500);
}
