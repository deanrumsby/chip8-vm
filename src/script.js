let wasm;

WebAssembly.instantiateStreaming(fetch("bin/chip8-vm.wasm")).then(
  (obj) => wasm = obj.instance.exports,
);

function frame() {
  return new Uint8ClampedArray(wasm.memory.buffer, wasm.frame_ptr(), 64 * 32 * 4);
}

