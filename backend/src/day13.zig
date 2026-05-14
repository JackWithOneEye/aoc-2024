const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");

const shared = @import("shared.zig");

const Day13 = @This();

pub fn partA(_: *anyopaque, _: std.mem.Allocator, input: []const u8) anyerror!u64 {
    return solve(input, 0);
}

pub fn partB(_: *anyopaque, _: std.mem.Allocator, input: []const u8) anyerror!u64 {
    return solve(input, 10000000000000);
}

pub fn build() Problem {
    var s = Day13{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}

fn parseButtonLine(line: []const u8) anyerror!struct { i64, i64 } {
    const comma_idx = std.mem.indexOf(u8, line, ",") orelse return error.InvalidParam;
    const x = try std.fmt.parseInt(i64, line["Button Z: X+".len..comma_idx], 10);
    const y = try std.fmt.parseInt(i64, line[comma_idx + " Y+".len + 1 ..], 10);
    return .{ x, y };
}

fn parsePrizeLine(line: []const u8) anyerror!struct { i64, i64 } {
    const comma_idx = std.mem.indexOf(u8, line, ",") orelse return error.InvalidParam;
    const x = try std.fmt.parseInt(i64, line["Prize: X=".len..comma_idx], 10);
    const y = try std.fmt.parseInt(i64, line[comma_idx + " Y=".len + 1 ..], 10);
    return .{ x, y };
}

fn solve(input: []const u8, offset: i64) anyerror!u64 {
    var line_iter = shared.lineIterator(input);

    var result: u64 = 0;
    return while (line_iter.peek()) |_| {
        const button_a = line_iter.next() orelse return error.InvalidParam;
        const ba = try parseButtonLine(button_a);
        const button_b = line_iter.next() orelse return error.InvalidParam;
        const bb = try parseButtonLine(button_b);
        const prize = line_iter.next() orelse return error.InvalidParam;
        const p = try parsePrizeLine(prize);
        _ = line_iter.next();

        const x_a = ba[0];
        const y_a = ba[1];
        const x_b = bb[0];
        const y_b = bb[1];
        const x = p[0] + offset;
        const y = p[1] + offset;

        const b = @divFloor(x_a * y - y_a * x, x_a * y_b - y_a * x_b);
        const a = @divFloor(x - x_b * b, x_a);

        result += if ((a * x_a + b * x_b == x) and (a * y_a + b * y_b == y))
            @intCast(a * 3 + b)
        else
            0;
    } else result;
}
