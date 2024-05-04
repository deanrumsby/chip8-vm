import { init, reset, load, step, frame, update, registers } from "./chip8.js";

let prevTime;
let running = false;
let loading = false;

let file;
let reader;

const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

function run(timeStamp) {
  if (prevTime === undefined) {
    prevTime = timeStamp;
  }
  const delta = timeStamp - prevTime;
  prevTime = timeStamp;

  if (!loading) {
    update(delta);
    refresh();
  }

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
  ctx.putImageData(image, 0, 0);
}

function refreshRegisters() {
  const pc = document.querySelector("#pc");
  pc.value = registers.pc.toString(16);
}

function handleFile(e) {
  file = e.target.files[0];
  loading = true;
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

function handleReset() {
  prevTime = undefined;
  reset();
  loading = true;
  reader.readAsArrayBuffer(file);
}

function initFileReader() {
  const filePicker = document.querySelector("#file");
  filePicker.addEventListener("change", handleFile);

  reader = new FileReader();
  reader.onload = (e) => {
    load(e.target.result);
    loading = false;
    if (!running) {
      refresh();
    }
  };
}

function initControlButtons() {
  const handlers = {
    play: handlePlay,
    pause: handlePause,
    step: handleStep,
    reset: handleReset,
  };
  const controls = document.querySelectorAll(".control");
  controls.forEach((c) => c.addEventListener("click", handlers[c.id]));
}

init(refresh);
initFileReader();
initControlButtons();
