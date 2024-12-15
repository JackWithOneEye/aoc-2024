const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");
const shared = @import("shared.zig");

const Day11 = @This();

pub fn partA(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    return exec(alloc, input, 25);
}

pub fn partB(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    return exec(alloc, input, 75);
}

pub fn build() Problem {
    var s = Day11{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}

fn exec(alloc: std.mem.Allocator, input: []const u8, comptime blinks: usize) anyerror!u64 {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    var splitter = Splitter(blinks).init(arena.allocator());
    var result: u64 = 0;
    var stone_it = std.mem.splitScalar(u8, input, ' ');

    return while (stone_it.next()) |stone| {
        result += try splitter.splitStone(stone, 0);
    } else result;
}

fn Splitter(comptime blinks: usize) type {
    return struct {
        const Self = @This();
        const Memo = std.StringHashMap([blinks]?u64);

        alloc: std.mem.Allocator,
        memo: Memo,

        fn init(alloc: std.mem.Allocator) Self {
            return .{ .alloc = alloc, .memo = Memo.init(alloc) };
        }

        fn splitStone(self: *Self, stone: []const u8, blink_ctr: usize) anyerror!u64 {
            if (blink_ctr == blinks) {
                return 1;
            }

            const memo_idx = blinks - 1 - blink_ctr;

            const memo = try self.memo.getOrPut(stone);
            if (!memo.found_existing) {
                memo.value_ptr.* = .{null} ** blinks;
            }
            if (memo.value_ptr.*[memo_idx]) |memod| {
                return memod;
            }

            const blink_ctr_incr = blink_ctr + 1;

            const res = if (std.mem.eql(u8, stone, "0"))
                try self.splitStone("1", blink_ctr_incr)
            else if (stone.len & 1 == 0) split: {
                const half = stone.len / 2;
                const res1 = try self.splitStone(stone[0..half], blink_ctr_incr);

                var latter = stone[half..];
                var begin: usize = 0;
                while (begin < latter.len - 1 and latter[begin] == '0') : (begin += 1) {}

                const res2 = try self.splitStone(latter[begin..], blink_ctr_incr);
                break :split res1 + res2;
            } else mult_2024: {
                var stone_uint = try std.fmt.parseUnsigned(u64, stone, 10);
                stone_uint *= 2024;
                const mult = try std.fmt.allocPrint(self.alloc, "{d}", .{stone_uint});
                break :mult_2024 try self.splitStone(mult, blink_ctr_incr);
            };

            memo.value_ptr.*[memo_idx] = res;
            return res;
        }
    };
}
