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

const favicon_format = "data:image/svg+xml;base64,{s}";

const style = @embedFile("static/style.css");
const script = @embedFile("static/script.js");
const favicon = @embedFile("static/favicon.svg");

pub fn generateHTML(cfg: config.Config, writer: *Writer) !void {
    const favicon_buf_size = comptime faviconHrefSize();
    comptime var favicon_href: [favicon_buf_size]u8 = undefined;
    comptime try faviconHref(&favicon_href);

    try writer.print(template_start, .{ cfg.title, style, favicon_href, script });
    for (cfg.groups) |group| {
        try writer.print(group_start, .{group.name});

        for (group.links) |link| {
            try writer.print(link_template, .{ link.url, link.name });
        }

        try writer.print(group_end, .{});
    }
    _ = try writer.write(template_end);
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
