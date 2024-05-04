const cpu = @import("./cpu.zig");
const Cpu = cpu.Cpu;
const PROG_START = cpu.PROG_START;
pub const Register = cpu.Register;
pub const FRAME_SIZE = cpu.FRAME_SIZE;

pub const Chip8 = struct {
    cpu: Cpu = Cpu{},

    pub fn init() Chip8 {
        return .{};
    }

    pub fn load(self: *Chip8, bytes: []const u8) void {
        self.cpu.load(bytes);
    }

    pub fn update(self: *Chip8, delta: f32) !void {
        try self.cpu.update(delta);
    }

    pub fn step(self: *Chip8) !void {
        try self.cpu.step();
    }

    pub fn frame_ptr(self: *Chip8) *const [FRAME_SIZE]u8 {
        return &self.cpu.frame;
    }

    pub fn prog_ptr(self: *Chip8) [*]const u8 {
        const base_ptr: [*]const u8 = &self.cpu.ram;
        return base_ptr + PROG_START;
    }

    pub fn get_register(self: *Chip8, register: Register) u32 {
        return self.cpu.get_register(register);
    }

    pub fn set_register(self: *Chip8, register: Register, value: u32) void {
        self.cpu.set_register(register, value);
    }
};
