let wasm;

WebAssembly.instantiateStreaming(fetch("./bin/chip8-vm.wasm")).then(
  (obj) => wasm = obj.instance.exports,
);

export function frame() {
  return new Uint8ClampedArray(wasm.memory.buffer, wasm.frame_ptr(), 64 * 32 * 4);
}

export function load(buffer) {
  const offset = wasm.ram_ptr() + 0x200;
  let dest = new Uint8Array(wasm.memory.buffer, offset, buffer.byteLength);
  dest.set(new Uint8Array(buffer));
}

export function step() {
  wasm.step();
}
