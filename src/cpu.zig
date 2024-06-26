const std = @import("std");
const testing = std.testing;

pub const PROG_START: u16 = 0x200;
pub const RAM_SIZE: usize = 4096;
pub const FRAME_SIZE: usize = 64 * 32 * 4;
const OPCODE_SIZE: u16 = 2;
const V_REG_COUNT: usize = 16;
const STACK_SIZE: usize = 16;
const DEFAULT_SPEED: f32 = 1000 / 700;

pub const Cpu = struct {
    pc: u16 = PROG_START,
    i: u16 = 0x0000,
    sp: u8 = 0x00,
    st: u8 = 0x00,
    dt: u8 = 0x00,
    v: [V_REG_COUNT]u8 = [_]u8{0} ** V_REG_COUNT,
    stack: [STACK_SIZE]u8 = [_]u8{0} ** STACK_SIZE,
    ram: [RAM_SIZE]u8 = [_]u8{0} ** RAM_SIZE,
    frame: [FRAME_SIZE]u8 = [_]u8{0} ** FRAME_SIZE,
    speed: f32 = DEFAULT_SPEED,
    time_acc: f32 = 0,

    pub fn init() Cpu {
        return .{};
    }

    pub fn load(self: *Cpu, bytes: []const u8) void {
        @memcpy(self.ram[PROG_START .. PROG_START + bytes.len], bytes);
    }

    pub fn reset(self: *Cpu) void {
        self.pc = PROG_START;
        self.i = 0x0000;
        self.sp = 0x00;
        self.st = 0x00;
        self.dt = 0x00;
        self.v = [_]u8{0} ** V_REG_COUNT;
        self.stack = [_]u8{0} ** STACK_SIZE;
        self.ram = [_]u8{0} ** RAM_SIZE;
        self.frame = [_]u8{0} ** FRAME_SIZE;
        self.speed = DEFAULT_SPEED;
        self.time_acc = 0;
    }

    pub fn update(self: *Cpu, delta: f32) !void {
        const total: f32 = self.time_acc + delta;
        const instructions: usize = @intFromFloat(total / self.speed);
        for (0..instructions) |_| {
            try self.step();
        }
        self.time_acc = total - @as(f32, @floatFromInt(instructions)) * self.speed;
    }

    pub fn step(self: *Cpu) !void {
        const opcode: u16 = self.fetch();
        self.pc += OPCODE_SIZE;
        const instruction = try self.decode(opcode);
        self.execute(instruction);
    }

    pub fn get_register(self: *Cpu, register: Register) u32 {
        return switch (register) {
            .PC => self.pc,
            .I => self.i,
            .SP => self.sp,
            .ST => self.st,
            .DT => self.dt,
            .V => |i| self.v[i],
        };
    }

    pub fn set_register(self: *Cpu, register: Register, value: u32) void {
        switch (register) {
            .PC => self.pc = @truncate(value),
            .I => self.i = @truncate(value),
            .SP => self.sp = @truncate(value),
            .ST => self.st = @truncate(value),
            .DT => self.dt = @truncate(value),
            .V => |i| self.v[i] = @truncate(value),
        }
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
                0x0 => .CLS,
                else => error.InvalidOpcode,
            },
            0x1 => .{ .JMP = nnn },
            0x6 => .{ .LDR = .{ &self.v[x], @intCast(nn) } },
            0x7 => .{ .ADD = .{ &self.v[x], @intCast(nn) } },
            0x8 => switch (n) {
                0x0 => .{ .LDR = .{ &self.v[x], self.v[y] } },
                else => error.InvalidOpcode,
            },
            0xa => .{ .LDI = nnn },
            0xb => .{ .JMP = nnn + self.v[0] },
            0xd => .{ .DRW = .{ self.v[x], self.v[y], @intCast(n) } },
            0xf => switch (nn) {
                0x07 => .{ .LDR = .{ &self.v[x], self.dt } },
                0x15 => .{ .LDR = .{ &self.dt, self.v[x] } },
                0x18 => .{ .LDR = .{ &self.st, self.v[x] } },
                else => error.InvalidOpcode,
            },
            else => error.InvalidOpcode,
        };
    }

    fn execute(self: *Cpu, instruction: Instruction) void {
        switch (instruction) {
            .ADD => |p| p[0].* +%= p[1],
            .CLS => self.frame = [_]u8{0} ** FRAME_SIZE,
            .DRW => |d| self.draw(d[0], d[1], d[2]),
            .JMP => |addr| self.pc = addr,
            .LDI => |word| self.i = word,
            .LDR => |p| p[0].* = p[1],
        }
    }

    fn draw(self: *Cpu, x: u8, y: u8, h: u4) void {
        const bytes = self.ram[self.i .. self.i + h];
        for (bytes, 0..h) |byte, i| {
            for (0..8) |j| {
                const offset = ((x + j) * 4) + ((y + i) * 64 * 4);
                const bit = std.math.shr(u8, byte, (7 - j)) & 1;
                const pixel = &self.frame[offset + 3];
                if (pixel.* == 1 and bit == 1) {
                    self.v[0xf] = 1;
                }
                pixel.* = if (pixel.* != bit) 0xff else 0;
            }
        }
    }
};

pub const Register = union(enum) {
    PC,
    I,
    SP,
    ST,
    DT,
    V: u4,
};

const Instruction = union(enum) {
    ADD: struct { *u8, u8 },
    CLS,
    DRW: struct { u8, u8, u4 },
    JMP: u16,
    LDI: u16,
    LDR: struct { *u8, u8 },
};

test "load" {
    var cpu = Cpu{};
    const bytes = [_]u8{ 0x45, 0x23, 0x36 };
    var end: usize = 2;
    end += 1;
    cpu.load(bytes[0..end]);
    try testing.expect(cpu.ram[PROG_START] == 0x45);
    try testing.expect(cpu.ram[PROG_START + 1] == 0x23);
    try testing.expect(cpu.ram[PROG_START + 2] == 0x36);
}

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

test "get_register" {
    var cpu = Cpu{};

    cpu.pc = 0x2255;
    cpu.st = 0xab;
    cpu.v[5] = 0xf1;

    try testing.expect(cpu.get_register(.PC) == cpu.pc);
    try testing.expect(cpu.get_register(.ST) == cpu.st);
    try testing.expect(cpu.get_register(.{ .V = 5 }) == cpu.v[5]);
}

test "set_register" {
    var cpu = Cpu{};

    cpu.set_register(.PC, 0x4512);
    cpu.set_register(.DT, 0x23);
    cpu.set_register(.{ .V = 2 }, 0x67);

    try testing.expect(cpu.pc == 0x4512);
    try testing.expect(cpu.dt == 0x23);
    try testing.expect(cpu.v[2] == 0x67);
}

test "ADD" {
    var cpu = Cpu{};
    cpu.v[2] = 0xff;
    cpu.execute(.{ .ADD = .{ &cpu.v[2], 0x01 } });
    try testing.expect(cpu.v[2] == 0x00);
}

test "CLS" {
    var cpu = Cpu{};
    cpu.frame[34] = 0x77;
    cpu.execute(.CLS);
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
