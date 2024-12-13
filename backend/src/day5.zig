const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");

const Day5 = @This();

pub fn partA(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var inp = try Input.init(alloc, input);
    defer inp.deinit();

    var result: u64 = 0;

    while (try inp.next()) |correct| {
        if (correct) {
            result += inp.pages.items[inp.pages.items.len / 2];
        }
    }

    return result;
}

pub fn partB(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var inp = try Input.init(alloc, input);
    defer inp.deinit();

    var result: u64 = 0;

    while (try inp.next()) |correct| {
        if (!correct) {
            result += inp.pages_sorted.items[inp.pages_sorted.items.len / 2];
        }
    }

    return result;
}

pub fn build() Problem {
    var s = Day5{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}

const Rules = std.AutoHashMap(struct { u64, u64 }, void);

fn parseU64(str: []const u8) anyerror!u64 {
    return std.fmt.parseUnsigned(u64, str, 10);
}

const Input = struct {
    rules: Rules,
    updates_iter: std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar),
    pages: std.ArrayList(u64),
    pages_sorted: std.ArrayList(u64),

    const Self = @This();

    fn init(alloc: std.mem.Allocator, input: []const u8) anyerror!Input {
        var lines_iter = std.mem.splitScalar(u8, input, '\n');

        var rules = Rules.init(alloc);

        while (lines_iter.next()) |line| {
            if (line.len == 0) {
                break;
            }

            var page_iter = std.mem.splitScalar(u8, line, '|');
            const first = page_iter.next() orelse return error.InvalidParam;
            const second = page_iter.next() orelse return error.InvalidParam;
            try rules.put(.{ try parseU64(first), try parseU64(second) }, {});
        }

        return .{
            .rules = rules,
            .updates_iter = lines_iter,
            .pages = std.ArrayList(u64).init(alloc),
            .pages_sorted = std.ArrayList(u64).init(alloc),
        };
    }

    fn next(self: *Input) anyerror!?bool {
        return if (self.updates_iter.next()) |line| {
            self.pages.clearRetainingCapacity();
            self.pages_sorted.clearRetainingCapacity();

            var pages_iter = std.mem.splitScalar(u8, line, ',');
            while (pages_iter.next()) |p| {
                const pp = try parseU64(p);
                try self.pages.append(pp);
                try self.pages_sorted.append(pp);
            }

            std.mem.sort(u64, self.pages_sorted.items, self, struct {
                pub fn inner(ctx: *Self, a: u64, b: u64) bool {
                    return ctx.rules.contains(.{ a, b });
                }
            }.inner);

            return std.mem.eql(u64, self.pages.items, self.pages_sorted.items);
        } else null;
    }

    fn deinit(self: *Input) void {
        self.rules.deinit();
        self.pages.deinit();
        self.pages_sorted.deinit();
    }
};
