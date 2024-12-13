const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");

const Day1 = @This();

pub fn partA(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var lists = try Lists(i32).init(alloc, input);
    defer lists.deinit();

    const left_sorted = try lists.left.toOwnedSlice();
    defer alloc.free(left_sorted);
    std.mem.sort(i32, left_sorted, {}, comptime std.sort.asc(i32));

    const right_sorted = try lists.right.toOwnedSlice();
    defer alloc.free(right_sorted);
    std.mem.sort(i32, right_sorted, {}, comptime std.sort.asc(i32));

    var result: u64 = 0;

    for (left_sorted, right_sorted) |l, r| {
        result += @abs(l - r);
    }
    return result;
}

pub fn partB(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var lists = try Lists(u64).init(alloc, input);
    defer lists.deinit();

    var result: u64 = 0;

    for (lists.left.items) |l| {
        for (lists.right.items) |r| {
            if (l == r) {
                result += l;
            }
        }
    }

    return result;
}

pub fn build() Problem {
    var s = Day1{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}

fn Lists(comptime T: type) type {
    return struct {
        left: std.ArrayList(T),
        right: std.ArrayList(T),

        pub fn init(alloc: std.mem.Allocator, input: []const u8) anyerror!Lists(T) {
            var left = try std.ArrayList(T).initCapacity(alloc, 1000);
            var right = try std.ArrayList(T).initCapacity(alloc, 1000);
            var it = std.mem.splitScalar(u8, input, '\n');
            while (it.next()) |line| {
                var lit = std.mem.splitSequence(u8, line, "   ");

                const l = lit.next() orelse return error.InvalidParam;
                const lv = try std.fmt.parseInt(T, l, 10);
                try left.append(lv);

                const r = lit.next() orelse return error.InvalidParam;
                const rv = try std.fmt.parseInt(T, r, 10);
                try right.append(rv);
            }

            return .{ .left = left, .right = right };
        }

        pub fn deinit(self: *Lists(T)) void {
            self.left.deinit();
            self.right.deinit();
        }
    };
}
