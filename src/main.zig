const std = @import("std");

// CPWD - Copy Present Working Directory
// 1. Get current working directory path
// 2. Detect operating system (macOS, Linux, or other)
// 3. Choose appropriate clipboard command based on OS
// 4. Create child process with clipboard command
// 5. Pipe the directory path to clipboard
// 6. Confirm operation completed successfully

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const cwd = try std.fs.cwd().realpathAlloc(allocator, ".");
    defer allocator.free(cwd);

    const clipboard_cmd = switch (@import("builtin").os.tag) {
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

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Copied: {s}\n", .{cwd});
}

fn isCommandAvailable(allocator: std.mem.Allocator, cmd: []const u8) bool {
    var process = std.process.Child.init(&[_][]const u8{ "which", cmd }, allocator);
    process.stdout_behavior = .Ignore;
    process.stderr_behavior = .Ignore;
    const result = process.spawnAndWait() catch return false;
    return result.Exited == 0;
}
