const std = @import("std");
const testing = std.testing;

const PROGRAM_START: u16 = 0x200;
const V_REG_COUNT: usize = 16;
const STACK_SIZE: usize = 16;
const RAM_SIZE: usize = 4096;

const Cpu = struct {
    pc: u16 = PROGRAM_START,
    i: u16 = 0x0000,
    sp: u8 = 0x00,
    st: u8 = 0x00,
    dt: u8 = 0x00,
    v: [V_REG_COUNT]u8 = [_]u8{0} ** V_REG_COUNT,
    stack: [STACK_SIZE]u8 = [_]u8{0} ** STACK_SIZE,
    ram: [RAM_SIZE]u8 = [_]u8{0} ** RAM_SIZE,

    fn fetch(self: *Cpu) u16 {
        const bytes: *const [2]u8 = @ptrCast(self.ram[self.pc .. self.pc + 2]);
        return std.mem.readInt(u16, bytes, .big);
    }

    fn execute(self: *Cpu, instruction: InstructionType) void {
        switch (instruction) {
            .JMP => |addr| self.pc = addr,
        }
    }
};

const Instruction = enum {
    JMP,
};

const InstructionType = union(Instruction) {
    JMP: u16,
};

test "fetch" {
    var cpu = Cpu{};
    cpu.ram[cpu.pc] = 0x12;
    cpu.ram[cpu.pc + 1] = 0x34;
    try testing.expect(cpu.fetch() == 0x1234);
}

test "JMP" {
    var cpu = Cpu{};
    cpu.execute(.{ .JMP = 0x45a2 });
    try testing.expect(cpu.pc == 0x45a2);
}
