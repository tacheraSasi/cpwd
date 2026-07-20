const std = @import("std");
const builtin = @import("builtin");
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const cwd = try std.Io.Dir.cwd();
    defer allocator.free(cwd);

    const clipboard_cmd = switch (builtin.os.tag) {
        .macos => "pbcopy",
        .linux => blk: {
            if (isCommandAvailable(allocator, "wl-copy")) {
                break :blk "wl-copy";
            }
            if (isCommandAvailable(allocator, "xclip")) {
                break :blk "xclip -selection clipboard";
            }
            return error.NoClipboardTool;
        },
        else => return error.UnsupportedOS,
    };

    var process = std.process.Child.init(&[_][]const u8{clipboard_cmd}, allocator);
    process.stdin_behavior = .Pipe;

    try process.spawn();

    try process.stdin.?.writeAll(cwd);
    process.stdin.?.close();
    process.stdin = null;

    _ = try process.wait();

    print("Copied: {s}\n", .{cwd});
}

fn isCommandAvailable(allocator: std.mem.Allocator, cmd: []const u8) bool {
    var process = std.process.Child.init(&[_][]const u8{ "which", cmd }, allocator);
    process.stdout_behavior = .Ignore;
    process.stderr_behavior = .Ignore;
    const result = process.spawnAndWait() catch return false;
    return result.Exited == 0;
}
