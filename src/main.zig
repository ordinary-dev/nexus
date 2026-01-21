const std = @import("std");
const config = @import("config.zig");
const args = @import("args.zig");
const template = @import("template.zig");

pub const std_options: std.Options = .{ .log_level = .info };

pub fn main() !u8 {
    const allocator = std.heap.page_allocator;

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);
    const parsedArgs = args.parseArgs(argv) catch {
        return 1;
    };

    const cfg = try config.parseConfigFile(parsedArgs.input_path, allocator);

    var html_file = try std.fs.cwd().createFile(parsedArgs.output_path, .{ .truncate = true });
    var html_buffer: [1024]u8 = undefined;
    var html_writer = html_file.writer(&html_buffer);
    try template.generateHTML(cfg, &html_writer.interface);

    return 0;
}
