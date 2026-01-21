const std = @import("std");
const config = @import("config.zig");
const Writer = std.Io.Writer;

const favicon_format = "data:image/svg+xml;base64,{s}";

const html = @embedFile("static/index.html");
const style = @embedFile("static/style.css");
const script = @embedFile("static/script.js");
const favicon = @embedFile("static/favicon.svg");

pub fn generateHTML(cfg: config.Config, writer: *Writer) !void {
    const favicon_buf_size = comptime faviconHrefSize();
    comptime var favicon_href: [favicon_buf_size]u8 = undefined;
    comptime try faviconHref(&favicon_href);

    // Split HTML template.
    const template_start_fmt = comptime strFromTo(html, "<!-- start -->", "<!-- group-start -->").?;
    const group_start_fmt = comptime strFromTo(html, "<!-- group-start -->", "<!-- link-start -->").?;
    const link_fmt = comptime strFromTo(html, "<!-- link-start -->", "<!-- link-end -->").?;
    const group_end_fmt = comptime strFromTo(html, "<!-- link-end -->", "<!-- group-end -->").?;
    const template_end_fmt = comptime strFromTo(html, "<!-- group-end -->", "<!-- end -->").?;

    try writer.print(template_start_fmt, .{ cfg.title, style, favicon_href, script });

    for (cfg.groups) |group| {
        try writer.print(group_start_fmt, .{group.name});

        for (group.links) |link| {
            try writer.print(link_fmt, .{ link.url, link.name });
        }

        try writer.print(group_end_fmt, .{});
    }
    _ = try writer.write(template_end_fmt);
    try writer.flush();
}

fn faviconHrefSize() usize {
    const b64 = std.base64.standard.Encoder;
    return favicon_format.len - 3 + b64.calcSize(favicon.len);
}

fn faviconHref(buffer: []u8) !void {
    @setEvalBranchQuota(10000);

    const b64 = std.base64.standard.Encoder;
    const b64_size = b64.calcSize(favicon.len);
    var favicon_b64: [b64_size]u8 = undefined;
    _ = b64.encode(&favicon_b64, favicon);

    _ = try std.fmt.bufPrint(buffer, favicon_format, .{favicon_b64});
}

// Extract substring between "from" and "to".
fn strFromTo(src: []const u8, from: []const u8, to: []const u8) ?[]const u8 {
    const start_idx = std.mem.indexOf(u8, src, from).?;
    const end_idx = std.mem.indexOf(u8, src, to).?;
    if (start_idx >= end_idx) return null;

    return src[start_idx + from.len .. end_idx];
}
