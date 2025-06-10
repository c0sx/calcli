const std = @import("std");

pub const Token = union(enum) {
    number: f64,
    plus,
    minus,
    multiply,
    divide,
    lparen,
    rparen,

    pub fn format(self: Token, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        switch (self) {
            .number => |n| try writer.print("[{d}]", .{n}),
            .plus => try writer.writeAll("[+]"),
            .minus => try writer.writeAll("[-]"),
            .multiply => try writer.writeAll("[*]"),
            .divide => try writer.writeAll("[/]"),
            .lparen => try writer.writeAll("[(]"),
            .rparen => try writer.writeAll("[)]"),
        }
    }
};

pub fn tokenize(input: []const u8, allocator: std.mem.Allocator) ![]Token {
    var list = std.ArrayList(Token).init(allocator);

    var i: usize = 0;
    while (i < input.len) {
        const c = input[i];

        if (std.ascii.isWhitespace(c)) {
            i+=1;
            continue;
        }

        if (std.ascii.isDigit(c)) {
            const start = i;

            while (i < input.len and (std.ascii.isDigit(input[i]) or input[i] == '.')) {
                i += 1;
            }

            const slice = input[start..i];
            const number = try std.fmt.parseFloat(f64, slice);
            try list.append(Token{ .number = number });
        }
        else {
            switch (c) {
                '+' => try list.append(Token.plus),
                '-' => try list.append(Token.minus),
                '*' => try list.append(Token.multiply),
                '/' => try list.append(Token.divide),
                '(' => try list.append(Token.lparen),
                ')' => try list.append(Token.rparen),
                else => return error.InvalidToken,
            }

            i += 1;
        }
    }

    return list.toOwnedSlice();
}

test "should tokenize input" {
    const allocator = std.testing.allocator;

    const input = "1+2";

    const tokens = try tokenize(input, allocator);
    defer allocator.free(tokens);

    try std.testing.expectEqual(tokens.len, 3);

    const str = try tokensToString(tokens, allocator);
    defer allocator.free(str);

    std.debug.print("DEBUG: \"{s}\"\n", .{str});
    try std.testing.expectEqualStrings("[1][+][2]", str);
}

fn tokensToString(tokens: []Token, allocator: std.mem.Allocator) ![]u8 {
    var list = std.ArrayList(u8).init(allocator);

    var writer = list.writer();
    for (tokens) |token| {
        try writer.print("{}", .{token});
    }

    return list.toOwnedSlice();
}
