const std = @import("std");
const Allocator = std.mem.Allocator;

const dev_line_len_minus_name = "Device XX:XX:XX:XX:XX:XX ".len;

pub fn reportErr(err: anyerror) void {
    //std.debug.print("\\{'error': '{s}'\\}", .{@errorName(err)});
    std.debug.print("{s}", .{@errorName(err)});
}

pub fn getDevicesStr(alloc: Allocator) ![]u8 {
    const argv = [_][]const u8{ "bluetoothctl", "devices" };
    const proc = try std.process.Child.run(.{
        .argv = &argv,
        .allocator = alloc,
    });
    defer alloc.free(proc.stderr);

    const dev_str_len: usize = for (proc.stdout, 0..) |c, i| {
        if (c == '[') {
            break i;
        }
    } else 0;
    return proc.stdout[0..dev_str_len];
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    const dev_str = getDevicesStr(alloc) catch |err| {
        reportErr(err);
        return;
    };

    var j: usize = 1;
    var dev_str_fmt = try alloc.alloc(u8, 2 * dev_str.len);
    dev_str_fmt[0] = '[';

    var line_iter = std.mem.splitScalar(u8, dev_str, '\n');
    while (line_iter.next()) |line| {
        if (line.len > 0) {
            if (j > 1) {
                dev_str_fmt[j] = ',';
                j += 1;
            }
            @memcpy(dev_str_fmt[j .. j + 9], "{\"addr\":\"");
            @memcpy(dev_str_fmt[j + 9 .. j + 26], line[7..24]);
            @memcpy(dev_str_fmt[j + 26 .. j + 36], "\",\"name\":\"");
            const name_len = line.len - dev_line_len_minus_name;
            @memcpy(dev_str_fmt[j + 36 .. j + 36 + name_len], line[dev_line_len_minus_name..]);
            @memcpy(dev_str_fmt[j + 36 + name_len .. j + 38 + name_len], "\"}");
            j += 38 + name_len;
        }
    }
    dev_str_fmt[j] = ']';

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    var stdout = &stdout_writer.interface;
    try stdout.print("{s}\n", .{dev_str_fmt[0 .. j + 1]});

    return;
}
