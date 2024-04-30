const std = @import("std");
const testing = std.testing;

const PROGRAM_START: u16 = 0x200;
const OPCODE_SIZE: u16 = 2;
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

    pub fn step(self: *Cpu) !void {
        const opcode: u16 = self.fetch();
        self.pc += OPCODE_SIZE;
        const instruction = try self.decode(opcode);
        self.execute(instruction);
    }

    fn fetch(self: *Cpu) u16 {
        const bytes: *const [2]u8 = @ptrCast(self.ram[self.pc .. self.pc + OPCODE_SIZE]);
        return std.mem.readInt(u16, bytes, .big);
    }

    fn decode(self: *Cpu, opcode: u16) !Instruction {
        const first = (opcode & 0xf000) >> 12;
        const x = (opcode & 0x0f00) >> 8;
        const y = (opcode & 0x00f0) >> 4;
        const nnn = opcode & 0x0fff;
        const nn = opcode & 0x00ff;
        const n = opcode & 0x000f;

        return switch (first) {
            0x0 => switch (n) {
                // 00E0
                0x0 => .{ .CLS = void{} },
                else => error.InvalidOpcode,
            },
            // 1NNN
            0x1 => .{ .JMP = nnn },
            // 6XNN
            0x6 => .{ .LDR = .{ &self.v[x], @intCast(nn) } },
            // 7XNN
            0x7 => .{ .ADD = .{ &self.v[x], @intCast(nn) } },
            0x8 => switch (n) {
                // 8XY0
                0x0 => .{ .LDR = .{ &self.v[x], self.v[y] } },
                else => error.InvalidOpcode,
            },
            // ANNN
            0xa => .{ .LDI = nnn },
            // BNNN
            0xb => .{ .JMP = nnn + self.v[0] },
            0xf => switch (nn) {
                // FX07
                0x07 => .{ .LDR = .{ &self.v[x], self.dt } },
                // FX15
                0x15 => .{ .LDR = .{ &self.dt, self.v[x] } },
                // FX18
                0x18 => .{ .LDR = .{ &self.st, self.v[x] } },
                else => error.InvalidOpcode,
            },
            else => error.InvalidOpcode,
        };
    }

    fn execute(self: *Cpu, instruction: Instruction) void {
        switch (instruction) {
            .ADD => |p| p[0].* = @addWithOverflow(p[0].*, p[1])[0],
            .CLS => self.frame = [_]u8{0} ** FRAME_SIZE,
            .JMP => |addr| self.pc = addr,
            .LDI => |word| self.i = word,
            .LDR => |p| p[0].* = p[1],
        }
    }
};

const Instruction = union(enum) {
    ADD: struct { *u8, u8 },
    CLS,
    JMP: u16,
    LDI: u16,
    LDR: struct { *u8, u8 },
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

test "step" {
    var cpu = Cpu{};

    cpu.ram[cpu.pc] = 0x17;
    cpu.ram[cpu.pc + 1] = 0x22;

    try cpu.step();
    try testing.expect(cpu.pc == 0x0722);
}

test "ADD" {
    var cpu = Cpu{};
    cpu.v[2] = 0x11;
    cpu.execute(.{ .ADD = .{ &cpu.v[2], 0x01 } });
    try testing.expect(cpu.v[2] == 0x12);
}

test "CLS" {
    var cpu = Cpu{};
    cpu.frame[34] = 0x77;
    cpu.execute(.{ .CLS = void{} });
    try testing.expect(cpu.frame[34] == 0);
}

test "JMP" {
    var cpu = Cpu{};
    cpu.execute(.{ .JMP = 0x45a2 });
    try testing.expect(cpu.pc == 0x45a2);
}

test "LDI" {
    var cpu = Cpu{};
    cpu.execute(.{ .LDI = 0x09b1 });
    try testing.expect(cpu.i == 0x09b1);
}

test "LDR" {
    var cpu = Cpu{};
    cpu.execute(.{ .LDR = .{ &cpu.dt, 0x11 } });
    try testing.expect(cpu.dt == 0x11);
    cpu.execute(.{ .LDR = .{ &cpu.v[3], 0xfa } });
    try testing.expect(cpu.v[3] == 0xfa);
}
