const std = @import("std");
const Yaml = @import("yaml").Yaml;

pub const Config = struct {
    title: []const u8,
    groups: []const Group,
};

const Group = struct {
    name: []const u8,
    links: []const Link,
};

const Link = struct {
    name: []const u8,
    url: []const u8,
};

pub fn parseConfigFile(filename: []const u8, alloc: std.mem.Allocator) !Config {
    const cfg_content = try std.fs.cwd().readFileAlloc(alloc, filename, std.math.maxInt(usize));
    defer alloc.free(cfg_content);

    return parseConfig(cfg_content, alloc);
}

pub fn parseConfig(source: []u8, allocator: std.mem.Allocator) !Config {
    var doc: Yaml = .{ .source = source };
    defer doc.deinit(allocator);

    try doc.load(allocator);
    return doc.parse(allocator, Config);
}
