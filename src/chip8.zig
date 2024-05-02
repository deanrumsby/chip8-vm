const Cpu = @import("./cpu.zig").Cpu;

pub const Chip8 = struct {
    cpu: Cpu = Cpu{},

    pub fn init() Chip8 {
        return .{};
    }

    pub fn load(self: *Chip8, bytes: []const u8) void {
        self.cpu.load(bytes);
    }

    pub fn update(self: *Chip8, delta: u32) !void {
        try self.cpu.update(delta);
    }

    pub fn step(self: *Chip8) !void {
        try self.cpu.step();
    }

    pub fn frame_ptr(self: *Chip8) *const [32 * 64 * 4]u8 {
        return &self.cpu.frame;
    }
};
