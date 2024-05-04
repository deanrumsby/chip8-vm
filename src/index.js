import { init, load, step, frame, update, registers } from "./chip8.js";

let prevTime;
let running = false;

function run(timeStamp) {
  if (prevTime === undefined) {
    prevTime = timeStamp;
  }
  const delta = timeStamp - prevTime;
  prevTime = timeStamp;
  update(delta);
  refresh();

  if (running) {
    window.requestAnimationFrame(run);
  }
}

function refresh() {
  refreshFrame();
  refreshRegisters();
}

function refreshFrame() {
  const image = new ImageData(frame(), 64, 32);
  canvas.getContext("2d").putImageData(image, 0, 0);
}

function refreshRegisters() {
  const pc = document.querySelector("#pc");
  pc.value = registers.pc.toString(16);
}

function handleFile(e) {
  const file = e.target.files[0];
  const reader = new FileReader();
  reader.onload = (e) => {
    load(e.target.result);
  };
  reader.readAsArrayBuffer(file);
}

function handleStep() {
  step();
  refresh();
}

function handlePlay() {
  running = true;
  window.requestAnimationFrame(run);
}

function handlePause() {
  running = false;
  prevTime = undefined;
}

const fileInput = document.getElementById("input");
fileInput.addEventListener("change", handleFile);

const stepButton = document.getElementById("step");
stepButton.addEventListener("click", handleStep);

const playButton = document.getElementById("play");
playButton.addEventListener("click", handlePlay);

const pauseButton = document.getElementById("pause");
pauseButton.addEventListener("click", handlePause);

const canvas = document.getElementById("canvas");

init(refresh);
