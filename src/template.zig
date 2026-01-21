const std = @import("std");
const config = @import("config.zig");
const Writer = std.Io.Writer;

const template_start =
    \\<!DOCTYPE html>
    \\<html>
    \\<head>
    \\  <meta charset="utf-8" />
    \\  <meta name="viewport" content="width=device-width, initial-scale=1" />
    \\  <title>{s}</title>
    \\  <style>
    \\    {s}
    \\  </style>
    \\  <link rel="icon" type="image/svg+xml" href="{s}" />
    \\  <script>
    \\    {s}
    \\  </script>
    \\</head>
    \\<body>
    \\  <input type="text" id="search" placeholder="Search (/)" />
    \\  <div class="groups">
    \\
;

const group_start =
    \\    <section>
    \\      <b>{s}</b>
    \\
;

const link_template =
    \\      <a href="{s}" target="_blank" rel="noreferer">{s}</a>
    \\
;

const group_end =
    \\    </section>
    \\
;

const template_end =
    \\  </div>
    \\</body>
    \\</html>
    \\
;

const style = @embedFile("static/style.css");
const script = @embedFile("static/script.js");
const favicon = @embedFile("static/favicon.svg");

pub fn generateHTML(allocator: std.mem.Allocator, cfg: config.Config, writer: *Writer) !void {
    const b64 = std.base64.standard.Encoder;
    const favicon_b64 = try allocator.alloc(u8, b64.calcSize(favicon.len));
    defer allocator.free(favicon_b64);
    _ = b64.encode(favicon_b64, favicon);

    const favicon_href = try std.fmt.allocPrint(allocator, "data:image/svg+xml;base64,{s}", .{favicon_b64});
    defer allocator.free(favicon_href);

    try writer.print(template_start, .{ cfg.title, style, favicon_href, script });
    for (cfg.groups) |group| {
        try writer.print(group_start, .{group.name});

        for (group.links) |link| {
            try writer.print(link_template, .{ link.url, link.name });
        }

        try writer.print(group_end, .{});
    }
    _ = try writer.write(template_end);
}
