const chip8 = @import("./chip8.zig").Chip8;

var instance = chip8.init();

export fn frame_ptr() *const [64 * 32 * 4]u8 {
    return &instance.cpu.frame;
}

export fn ram_ptr() *const [4096]u8 {
    return &instance.cpu.ram;
}

export fn update(delta: f32) f32 {
    instance.update(delta) catch return 1;
    return 0;
}

export fn step() f32 {
    instance.step() catch return 1;
    return 0;
}
