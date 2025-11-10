const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const network_module = b.createModule(.{
        .root_source_file = b.path("src/network.zig"),
        .target = target,
        .optimize = optimize,
    });
    const network = b.addExecutable(.{
        .name = "network",
        .root_module = network_module,
    });
    b.installArtifact(network);

    const bt_module = b.createModule(.{
        .root_source_file = b.path("src/bt.zig"),
        .target = target,
        .optimize = optimize,
    });
    const bt = b.addExecutable(.{
        .name = "bt",
        .root_module = bt_module,
    });
    b.installArtifact(bt);

    const pomo_click_handler_module = b.createModule(.{
        .root_source_file = b.path("src/pomo_click_handler.zig"),
        .target = target,
        .optimize = optimize,
    });
    const pomo_click_handler = b.addExecutable(.{
        .name = "pomo_click_handler",
        .root_module = pomo_click_handler_module,
    });
    b.installArtifact(pomo_click_handler);
}
