const std = @import("std");

const Args = struct {
    input_path: []const u8 = undefined,
    output_path: []const u8 = undefined,
};

const USAGE =
    \\Usage: {s} [-o index.html] LINKS.yaml
    \\
    \\Parameters:
    \\  -o: path to the output file (defaults to index.html).
    \\
;

const ArgParseError = error{ MissingArgs, InvalidArgs };

pub fn parseArgs(argv: [][:0]u8) ArgParseError!Args {
    var args = Args{
        .output_path = "index.html",
    };

    if (argv.len < 2) {
        printUsage(argv[0]);
        return error.MissingArgs;
    }

    var idx: usize = 1;
    while (idx < argv.len and argv[idx].len > 0 and argv[idx][0] == '-') {
        if (std.mem.eql(u8, argv[idx], "-o")) {
            idx += 1;
            args.output_path = try readArg(argv, &idx);
        } else {
            printUsage(argv[0]);
            return error.InvalidArgs;
        }

        idx += 1;
    }

    args.input_path = try readArg(argv, &idx);
    return args;
}

fn readArg(argv: [][:0]u8, idx: *usize) ![]u8 {
    if (idx.* >= argv.len) {
        printUsage(argv[0]);
        return error.InvalidArgs;
    }
    return argv[idx.*];
}

fn printUsage(first_arg: [:0]u8) void {
    std.debug.print(USAGE, .{first_arg});
}
