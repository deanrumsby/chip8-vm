const std = @import("std");
const testing = std.testing;

const PROGRAM_START: u16 = 0x200;
const V_REG_COUNT: usize = 16;
const STACK_SIZE: usize = 16;
const RAM_SIZE: usize = 4096;
const FRAME_SIZE: usize = 64 * 32 * 4;

pub const Cpu = struct {
    pc: u16 = PROGRAM_START,
    i: u16 = 0x0000,
    sp: u8 = 0x00,
    st: u8 = 0x00,
    dt: u8 = 0x00,
    v: [V_REG_COUNT]u8 = [_]u8{0} ** V_REG_COUNT,
    stack: [STACK_SIZE]u8 = [_]u8{0} ** STACK_SIZE,
    ram: [RAM_SIZE]u8 = [_]u8{0} ** RAM_SIZE,
    frame: [FRAME_SIZE]u8 = [_]u8{0} ** FRAME_SIZE,

    pub fn init() Cpu {
        return .{};
    }

    fn fetch(self: *Cpu) u16 {
        const bytes: *const [2]u8 = @ptrCast(self.ram[self.pc .. self.pc + 2]);
        return std.mem.readInt(u16, bytes, .big);
    }

    fn decode(self: *Cpu, opcode: u16) !Instruction {
        const first = (opcode & 0xf000) >> 12;
        // const x = (opcode & 0x0f00) >> 8;
        // const y = (opcode & 0x00f0) >> 4;
        const nnn = opcode & 0x0fff;
        // const nn = opcode & 0x00ff;
        // const n = opcode & 0x000f;

        return switch (first) {
            0x1 => .{ .JMP = nnn },
            0xb => .{ .JMP = nnn + self.v[0] },
            else => error.InvalidOpcode,
        };
    }

    fn execute(self: *Cpu, instruction: Instruction) void {
        switch (instruction) {
            .JMP => |addr| self.pc = addr,
        }
    }
};

const Instruction = union(enum) {
    JMP: u16,
};

test "fetch" {
    var cpu = Cpu{};
    cpu.ram[cpu.pc] = 0x12;
    cpu.ram[cpu.pc + 1] = 0x34;
    try testing.expect(cpu.fetch() == 0x1234);
}

test "decode" {
    var cpu = Cpu{};

    var instruction = cpu.decode(0x1234);
    try testing.expectEqual(instruction, Instruction{ .JMP = 0x234 });

    cpu.v[0] = 0x22;
    instruction = cpu.decode(0xb561);
    try testing.expectEqual(instruction, Instruction{ .JMP = 0x583 });
}

test "JMP" {
    var cpu = Cpu{};
    cpu.execute(.{ .JMP = 0x45a2 });
    try testing.expect(cpu.pc == 0x45a2);
}
