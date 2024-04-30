const chip8 = @import("./chip8.zig").Chip8;

var instance = chip8.init();

export fn frame_ptr() *const [64 * 32 * 4]u8 {
    return instance.frame_ptr();
}
