const std = @import("std");

const tokenizer = @import("tokenizer.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: calcli <expression>\n", .{});
        return;
    }

    const input = args[1];
    const tokens = try tokenizer.tokenize(input, allocator);
    defer allocator.free(tokens);

    std.debug.print("tokens: {any}\n", .{tokens});
}
