const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");

const DayX = @This();

pub fn partA(_: *anyopaque, _: std.mem.Allocator, _: []const u8) anyerror!u64 {
    return 0;
}

pub fn partB(_: *anyopaque, _: std.mem.Allocator, _: []const u8) anyerror!u64 {
    return 0;
}

pub fn build() Problem {
    var s = DayX{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}
