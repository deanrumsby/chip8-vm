let wasm;

WebAssembly.instantiateStreaming(fetch("zig-out/bin/chip8-vm.wasm")).then(
  (obj) => wasm = obj.instance.exports,
);
