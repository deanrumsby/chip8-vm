import { load, step, frame } from "./chip8.js";

function handleFile(e) {
  const file = e.target.files[0];
  const reader = new FileReader();
  reader.onload = (e) => {
          load(e.target.result);
  }
  reader.readAsArrayBuffer(file);
}

function handleStep() {
  step();
  const image = new ImageData(frame(), 64, 32);
  canvas.getContext("2d").putImageData(image, 0, 0);
}

const fileInput = document.getElementById("input");
fileInput.addEventListener("change", handleFile);

const stepButton = document.getElementById("step");
stepButton.addEventListener("click", handleStep);

const canvas = document.getElementById("canvas");
