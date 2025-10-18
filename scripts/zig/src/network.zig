const std = @import("std");

pub fn reportErr(err: anyerror) void {
    //std.debug.print("\\{'error': '{s}'\\}", .{@errorName(err)});
    std.debug.print("{s}", .{@errorName(err)});
}

pub fn main() void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    var stdout = &stdout_writer.interface;

    const argv = [_][]const u8{ "nmcli", "-t", "-c", "no", "device" };
    const proc = std.process.Child.run(.{
        .argv = &argv,
        .allocator = alloc,
    }) catch |err| {
        reportErr(err);
        return;
    };
    defer alloc.free(proc.stderr);
    defer alloc.free(proc.stdout);

    stdout.print("{s}", .{proc.stdout}) catch |err| {
        reportErr(err);
        return;
    };
    return;
}
