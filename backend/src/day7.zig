const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");

const Day7 = @This();

pub fn partA(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    return solve(alloc, input, struct {
        pub fn inner(first: u64, operands: []u64, expected: u64) bool {
            if (operands.len == 0) {
                return first == expected;
            }
            if (first > expected) {
                return false;
            }

            const add = first + operands[0];
            const mult = first * operands[0];
            const rest = operands[1..];

            return inner(add, rest, expected) or inner(mult, rest, expected);
        }
    }.inner);
}

pub fn partB(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    return solve(alloc, input, struct {
        pub fn inner(first: u64, operands: []u64, expected: u64) bool {
            if (operands.len == 0) {
                return first == expected;
            }
            if (first > expected) {
                return false;
            }

            const add = first + operands[0];
            const mult = first * operands[0];

            var pow_10: u64 = 1;
            const concat = while (pow_10 <= operands[0]) {
                pow_10 *= 10;
            } else first * pow_10 + operands[0];

            const rest = operands[1..];

            return inner(add, rest, expected) or inner(mult, rest, expected) or inner(concat, rest, expected);
        }
    }.inner);
}

pub fn build() Problem {
    var s = Day7{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}

fn solve(alloc: std.mem.Allocator, input: []const u8, predicate: fn (first: u64, operands: []u64, expected: u64) bool) anyerror!u64 {
    var operands = std.ArrayList(u64).init(alloc);
    defer operands.deinit();

    var lines_iter = std.mem.splitScalar(u8, input, '\n');

    var result: u64 = 0;
    while (lines_iter.next()) |line| {
        defer operands.clearRetainingCapacity();

        var line_it = std.mem.splitSequence(u8, line, ": ");
        const test_val = try std.fmt.parseUnsigned(u64, line_it.next() orelse unreachable, 10);

        var operands_it = std.mem.splitScalar(u8, line_it.next() orelse unreachable, ' ');
        while (operands_it.next()) |o| {
            const ou = try std.fmt.parseUnsigned(u64, o, 10);
            try operands.append(ou);
        }

        if (predicate(operands.items[0], operands.items[1..], test_val)) {
            result += test_val;
        }
    }

    return result;
}
