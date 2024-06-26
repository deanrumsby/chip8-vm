const chip8 = @import("./chip8.zig");
const Chip8 = chip8.Chip8;
const Register = chip8.Register;
const FRAME_SIZE = chip8.FRAME_SIZE;

var instance = Chip8.init();

export fn reset() void {
    return instance.reset();
}

export fn pc() u32 {
    return instance.get_register(.PC);
}

export fn set_pc(value: u32) void {
    instance.set_register(.PC, value);
}

export fn i() u32 {
    return instance.get_register(.I);
}

export fn set_i(value: u32) void {
    instance.set_register(.I, value);
}

export fn sp() u32 {
    return instance.get_register(.SP);
}

export fn set_sp(value: u32) void {
    instance.set_register(.SP, value);
}

export fn st() u32 {
    return instance.get_register(.ST);
}

export fn set_st(value: u32) void {
    instance.set_register(.ST, value);
}

export fn dt() u32 {
    return instance.get_register(.DT);
}

export fn set_dt(value: u32) void {
    instance.set_register(.DT, value);
}

export fn v(j: u32) u32 {
    return instance.get_register(.{ .V = @truncate(j) });
}

export fn set_v(j: u32, value: u32) void {
    instance.set_register(.{ .V = @truncate(j) }, value);
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
