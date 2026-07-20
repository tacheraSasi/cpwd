const std = @import("std");
const builtin = @import("builtin");
const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    const cwd = try std.process.currentPathAlloc(io, allocator);
    defer allocator.free(cwd);

    const argv: []const []const u8 = switch (builtin.os.tag) {
        .macos => &[_][]const u8{"pbcopy"},
        .linux => blk: {
            if (isCommandAvailable(io, "wl-copy")) {
                break :blk &[_][]const u8{"wl-copy"};
            }
            if (isCommandAvailable(io, "xclip")) {
                break :blk &[_][]const u8{ "xclip", "-selection", "clipboard" };
            }
            return error.NoClipboardTool;
        },
        else => return error.UnsupportedOS,
    };

    var child = try std.process.spawn(io, .{
        .argv = argv,
        .stdin = .pipe,
    });

    try std.Io.File.writeStreamingAll(child.stdin.?, io, cwd);
    std.Io.File.close(child.stdin.?, io);
    child.stdin = null;

    _ = try child.wait(io);

    print("Copied: {s}\n", .{cwd});
}

fn isCommandAvailable(io: std.Io, cmd: []const u8) bool {
    var child = std.process.spawn(io, .{
        .argv = &[_][]const u8{ "which", cmd },
        .stdin = .ignore,
        .stdout = .ignore,
        .stderr = .ignore,
    }) catch return false;
    const term = child.wait(io) catch return false;
    return switch (term) {
        .exited => |code| code == 0,
        else => false,
    };
}
