const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");

const Coordinate = @import("shared.zig").Coordinate;

const Day8 = @This();

pub fn partA(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var frequencies = try Frequencies.init(alloc, input);
    defer frequencies.deinit();

    var antinodes = std.AutoHashMap(Coordinate, void).init(alloc);
    defer antinodes.deinit();

    var freq_it = frequencies.freqs.valueIterator();
    while (freq_it.next()) |antennas| {
        defer antennas.deinit();
        for (antennas.items, 0..) |antenna, i| {
            for (antennas.items[i + 1 ..]) |other| {
                const a1 = antenna.add(antenna.diff(other));
                if (frequencies.isInBound(a1)) {
                    try antinodes.put(a1, {});
                }
                const a2 = other.add(other.diff(antenna));
                if (frequencies.isInBound(a2)) {
                    try antinodes.put(a2, {});
                }
            }
        }
    }

    return antinodes.count();
}

pub fn partB(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var frequencies = try Frequencies.init(alloc, input);
    defer frequencies.deinit();

    var antinodes = std.AutoHashMap(Coordinate, void).init(alloc);
    defer antinodes.deinit();

    var freq_it = frequencies.freqs.valueIterator();
    while (freq_it.next()) |antennas| {
        defer antennas.deinit();
        for (antennas.items, 0..) |antenna, i| {
            try antinodes.put(antenna, {});
            for (antennas.items[i + 1 ..]) |other| {
                var diff = antenna.diff(other);
                var antinode = antenna.add(diff);
                while (frequencies.isInBound(antinode)) : (antinode = antinode.add(diff)) {
                    try antinodes.put(antinode, {});
                }

                diff = other.diff(antenna);
                antinode = other.add(diff);
                while (frequencies.isInBound(antinode)) : (antinode = antinode.add(diff)) {
                    try antinodes.put(antinode, {});
                }
            }
        }
    }

    return antinodes.count();
}

pub fn build() Problem {
    var s = Day8{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}

const Frequencies = struct {
    freqs: std.AutoHashMap(u8, std.ArrayList(Coordinate)),
    cols: i32,
    rows: i32,

    fn init(alloc: std.mem.Allocator, input: []const u8) anyerror!Frequencies {
        var freqs = std.AutoHashMap(u8, std.ArrayList(Coordinate)).init(alloc);

        var lines_iter = std.mem.splitScalar(u8, input, '\n');

        const cols: i32 = @intCast(lines_iter.peek().?.len);
        var y: i32 = 0;
        while (lines_iter.next()) |line| : (y += 1) {
            for (line, 0..) |char, x| {
                if (char == '.') {
                    continue;
                }
                var res = try freqs.getOrPut(char);
                if (!res.found_existing) {
                    res.value_ptr.* = std.ArrayList(Coordinate).init(alloc);
                }
                try res.value_ptr.append(.{ .x = @intCast(x), .y = y });
            }
        }

        return .{ .freqs = freqs, .cols = cols, .rows = y };
    }

    fn deinit(self: *Frequencies) void {
        self.freqs.deinit();
    }

    fn isInBound(self: *Frequencies, antinode: Coordinate) bool {
        return antinode.x >= 0 and antinode.x < self.cols and antinode.y >= 0 and antinode.y < self.rows;
    }
};
