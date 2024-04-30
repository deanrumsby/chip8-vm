const Cpu = @import("./cpu.zig").Cpu;

pub const Chip8 = struct {
    cpu: Cpu = Cpu{},

    pub fn init() Chip8 {
        return .{};
    }

    pub fn frame_ptr(self: *Chip8) *const [32 * 64 * 4]u8 {
        return &self.cpu.frame;
    }
};