const std = @import("std");

pub fn main() !void {
    // Get the allocator
    const allocator = std.heap.page_allocator;

    // Get the current working directory
    const cwd = try std.fs.cwd().realpathAlloc(allocator, ".");
    defer allocator.free(cwd);

    // Determine the operating system and appropriate clipboard command
    const clipboard_cmd = switch (@import("builtin").os.tag) {
        .macos => "pbcopy",
        .linux => blk: {
            // Check if wl-copy is available (Wayland)
            if (isCommandAvailable(allocator, "wl-copy")) {
                break :blk "wl-copy";
            }
            // Fall back to xclip for X11
            if (isCommandAvailable(allocator, "xclip")) {
                break :blk "xclip -selection clipboard";
            }
            return error.NoClipboardTool;
        },
        else => return error.UnsupportedOS,
    };

    // Opens a pipe to the clipboard command
    var process = std.process.Child.init(&[_][]const u8{clipboard_cmd}, allocator);
    process.stdin_behavior = .Pipe;

    // Spawn the process
    try process.spawn();

    // Write the current working directory to the clipboard
    try process.stdin.?.writeAll(cwd);
    process.stdin.?.close();
    process.stdin = null;

    // Wait for the process to finish
    _ = try process.wait();

    // Print confirmation
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Copied: {s}\n", .{cwd});
}

// Check if a command is available on the system
fn isCommandAvailable(allocator: std.mem.Allocator, cmd: []const u8) bool {
    var process = std.process.Child.init(&[_][]const u8{ "which", cmd }, allocator);
    process.stdout_behavior = .Ignore;
    process.stderr_behavior = .Ignore;
    const result = process.spawnAndWait() catch return false;
    return result.Exited == 0;
}
