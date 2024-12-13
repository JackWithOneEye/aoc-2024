const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");

const Day2 = @This();

pub fn partA(_: *anyopaque, _: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var safe_reports: u64 = 0;
    while (it.next()) |line| {
        //std.debug.print("{s}\n", .{line});
        var lit = std.mem.splitSequence(u8, line, " ");

        var prev = try std.fmt.parseInt(i32, lit.first(), 10);
        var prev_diff: i32 = 0;

        safe_reports += 1;
        while (lit.next()) |level| {
            const lvl = try std.fmt.parseInt(i32, level, 10);

            const diff = lvl - prev;

            if (isUnsafe(diff, prev_diff)) {
                safe_reports -= 1;
                break;
            }
            prev = lvl;
            prev_diff = diff;
        }
    }

    return safe_reports;
}

pub fn partB(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var it = std.mem.splitScalar(u8, input, '\n');
    var safe_reports: u64 = 0;

    var levels_list = try std.ArrayList(i32).initCapacity(alloc, 64);
    defer levels_list.deinit();

    outer: while (it.next()) |line| {
        var levels = std.mem.splitSequence(u8, line, " ");
        while (levels.next()) |lvl| {
            const l = try std.fmt.parseInt(i32, lvl, 10);
            try levels_list.append(l);
        }
        defer levels_list.clearRetainingCapacity();

        safe_reports += 1;
        const num_levels = levels_list.items.len;
        const faulty_lvl = findFaultyLevel(&levels_list, num_levels);
        if (faulty_lvl < num_levels) {
            for (0..num_levels) |i| {
                if (findFaultyLevel(&levels_list, i) == num_levels) {
                    continue :outer;
                }
            }
            safe_reports -= 1;
        }
    }

    return safe_reports;
}

fn findFaultyLevel(levels: *std.ArrayList(i32), skip_index: usize) usize {
    var prev_diff: i32 = 0;
    var prev: i32 = levels.items[0];
    var start_idx: usize = 1;
    if (skip_index == 0) {
        prev = levels.items[1];
        start_idx = 2;
    }
    for (levels.items[start_idx..], start_idx..) |level, i| {
        if (skip_index == i) {
            continue;
        }
        const diff = level - prev;
        if (isUnsafe(diff, prev_diff)) {
            return i;
        }
        prev = level;
        prev_diff = diff;
    }
    return levels.items.len;
}

fn isUnsafe(diff: i32, prev_diff: i32) bool {
    const diff_abs = @abs(diff);
    return diff_abs < 1 or diff_abs > 3 or (prev_diff < 0 and diff > 0) or (prev_diff > 0 and diff < 0);
}

pub fn build() Problem {
    var s = Day2{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}
