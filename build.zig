const std = @import("std");

const release_targets: []const std.Target.Query = &.{
    .{ .cpu_arch = .aarch64, .os_tag = .freebsd },
    .{ .cpu_arch = .aarch64, .os_tag = .linux },
    .{ .cpu_arch = .aarch64, .os_tag = .macos },
    .{ .cpu_arch = .aarch64, .os_tag = .windows },
    .{ .cpu_arch = .x86_64, .os_tag = .freebsd },
    .{ .cpu_arch = .x86_64, .os_tag = .linux },
    .{ .cpu_arch = .x86_64, .os_tag = .windows },
};

const manifest = @import("build.zig.zon");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const version: std.SemanticVersion = try .parse(manifest.version);

    const enable_cross_compilation = b.option(bool, "enable-cross-compilation", "Enable all supported targets") orelse false;
    const targets: []const std.Target.Query = if (enable_cross_compilation) release_targets else &.{.{}};

    for (targets) |t| {
        const target = b.resolveTargetQuery(t);

        const mod = b.addModule("nexus", .{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        });

        const yaml = b.dependency("zig_yaml", .{
            .target = target,
            .optimize = optimize,
        });

        const exe = b.addExecutable(.{
            .name = try getExeName(b.allocator, enable_cross_compilation, t, version),
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/main.zig"),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "nexus", .module = mod },
                    .{ .name = "yaml", .module = yaml.module("yaml") },
                },
                .strip = optimize != .Debug,
            }),
        });

        if (optimize != .Debug) {
            exe.lto = if (target.result.os.tag != .macos) .full else .none;
        }

        b.installArtifact(exe);

        if (!enable_cross_compilation) {
            const run_step = b.step("run", "Run the app");
            const run_cmd = b.addRunArtifact(exe);
            run_step.dependOn(&run_cmd.step);
            run_cmd.step.dependOn(b.getInstallStep());

            if (b.args) |args| {
                run_cmd.addArgs(args);
            }

            const mod_tests = b.addTest(.{
                .root_module = mod,
            });

            const run_mod_tests = b.addRunArtifact(mod_tests);

            const exe_tests = b.addTest(.{
                .root_module = exe.root_module,
            });

            const run_exe_tests = b.addRunArtifact(exe_tests);

            const test_step = b.step("test", "Run tests");
            test_step.dependOn(&run_mod_tests.step);
            test_step.dependOn(&run_exe_tests.step);
        }
    }
}

// Returns "nexus" if only one target is enabled, "nexus-v0.0.0-arch-os" otherwise.
fn getExeName(allocator: std.mem.Allocator, enable_cross_compilation: bool, target: std.Target.Query, v: std.SemanticVersion) ![]const u8 {
    if (!enable_cross_compilation) {
        return "nexus";
    }

    const triple = try target.zigTriple(allocator);
    return try std.fmt.allocPrint(allocator, "nexus-v{d}.{d}.{d}-{s}", .{ v.major, v.minor, v.patch, triple });
}
