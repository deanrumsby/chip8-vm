let wasm;

export function init(callback) {
  WebAssembly.instantiateStreaming(fetch("./bin/chip8-vm.wasm"))
    .then((obj) => (wasm = obj.instance.exports))
    .then(() => callback());
}

export const registers = {
  get pc() {
    return wasm.pc();
  },

  set pc(value) {
    wasm.set_pc(value);
  },
};

export function reset() {
  wasm.reset();
}

export function frame() {
  return new Uint8ClampedArray(
    wasm.memory.buffer,
    wasm.frame_ptr(),
    wasm.frame_size(),
  );
}

export function load(buffer) {
  let dest = new Uint8Array(
    wasm.memory.buffer,
    wasm.prog_ptr(),
    buffer.byteLength,
  );
  dest.set(new Uint8Array(buffer));
}

export function update(delta) {
  wasm.update(delta);
}

export function step() {
  wasm.step();
}
