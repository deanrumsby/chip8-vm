let wasm;

export function init(callback) {
  WebAssembly.instantiateStreaming(fetch("./bin/chip8-vm.wasm"))
    .then((obj) => (wasm = obj.instance.exports))
    .then(() => callback());
}

export function get_register(register, index) {
  const map = {
    pc: wasm.pc,
    i: wasm.i,
    sp: wasm.sp,
    st: wasm.st,
    dt: wasm.dt,
    v: wasm.v,
  };
  if (index) {
    return map[register](index);
  }
  return map[register]();
}

export function set_register(register, index, value) {
  const map = {
    pc: wasm.set_pc,
    i: wasm.set_i,
    sp: wasm.set_sp,
    st: wasm.set_st,
    dt: wasm.set_dt,
    v: wasm.set_v,
  };
  if (index) {
    map[register](index, value);
  }
  map[register](value);
}

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
