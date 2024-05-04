const chip8 = @import("./chip8.zig");
const Chip8 = chip8.Chip8;
const FRAME_SIZE = chip8.FRAME_SIZE;

var instance = Chip8.init();

export fn pc() u16 {
    return instance.cpu.pc;
}

export fn i() u16 {
    return instance.cpu.i;
}

export fn frame_ptr() *const [FRAME_SIZE]u8 {
    return instance.frame_ptr();
}

export fn frame_size() u32 {
    return FRAME_SIZE;
}

export fn prog_ptr() [*]const u8 {
    return instance.prog_ptr();
}

export fn update(delta: f32) f32 {
    instance.update(delta) catch return 1;
    return 0;
}

export fn step() f32 {
    instance.step() catch return 1;
    return 0;
}
