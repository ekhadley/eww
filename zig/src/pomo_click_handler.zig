const std = @import("std");
const Allocator = std.mem.Allocator;

// when we start a timer, we want to create an at job that will show the timer when time is up.
// this script

pub fn main() !void {
    var args = std.process.args();
    _ = args.next();
    const timer_id_str = args.next() orelse return error.MissingArgument;
    const state = args.next() orelse return error.MissingArgument;
    const duration_str = args.next() orelse return error.MissingArgument;

    const timer_id = std.fmt.parseInt(u8, timer_id_str, 10) catch {
        std.debug.print("Invalid timer id: {s}\n", .{timer_id_str});
        return error.InvalidArgument;
    };
    const duration = std.fmt.parseInt(u64, duration_str, 10) catch {
        std.debug.print("Invalid duration: {s}\n", .{duration_str});
        return error.InvalidArgument;
    };

    const t = std.time.timestamp();
    std.debug.print("timer_id: {d}, state: {s}, duration: {d}, current time :{d}\n", .{ timer_id, state, duration, t });

    //const new_state = if (state == "running") "paused" else "running";
    //const timer_name = if (timer_id == 1) "pomo1" else "pomo2";

    return;
}
