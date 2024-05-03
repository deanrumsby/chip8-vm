let wasm;

const PROG_START = 0x200;
const FRAME_SIZE = 64 * 32 * 4;

WebAssembly.instantiateStreaming(fetch("./bin/chip8-vm.wasm")).then(
  (obj) => (wasm = obj.instance.exports),
);

export function pc() {
  return wasm.pc();
}

export function frame() {
  return new Uint8ClampedArray(
    wasm.memory.buffer,
    wasm.frame_ptr(),
    FRAME_SIZE,
  );
}

export function load(buffer) {
  const offset = wasm.ram_ptr() + PROG_START;
  let dest = new Uint8Array(wasm.memory.buffer, offset, buffer.byteLength);
  dest.set(new Uint8Array(buffer));
}

export function update(delta) {
  wasm.update(delta);
}

export function step() {
  wasm.step();
}
