const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });

    const exe = b.addExecutable(.{
        .name = "chip8-vm",
        .root_source_file = .{ .path = "src/wasm.zig" },
        .target = target,
        .optimize = .Debug,
    });

    exe.entry = .disabled;
    exe.rdynamic = true;

    b.installFile("src/chip8.js", "chip8.js");
    b.installFile("src/index.html", "index.html");
    b.installFile("src/index.js", "index.js");
    b.installArtifact(exe);
}
