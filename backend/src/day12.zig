const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");

const shared = @import("shared.zig");
const Coordinate = shared.Coordinate;
const CoordinateSet = shared.CoordinateSet;
const Direction = shared.Direction;

const Day12 = @This();

pub fn partA(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const a_alloc = arena.allocator();

    var grid = try parseInput(a_alloc, input);

    var plotted = CoordinateSet.init(a_alloc);
    var grid_iter = grid.iterator();

    var result: u64 = 0;
    while (grid_iter.next()) |entry| {
        if (plotted.has(entry.key_ptr.*)) {
            continue;
        }
        const plant = entry.value_ptr.*;
        var perimeter: u64 = 4;
        var area: u64 = 1;

        var queue = shared.Queue(Coordinate).init(a_alloc);
        try plotted.add(entry.key_ptr.*);
        try queue.push(entry.key_ptr.*);

        while (queue.remove()) |coord| {
            inline for (directions) |dir| {
                const neighbour = coord.add(dir);
                if (grid.get(neighbour) == plant) {
                    perimeter -= 1;
                    if (!plotted.has(neighbour)) {
                        area += 1;
                        perimeter += 4;
                        try plotted.add(neighbour);
                        try queue.push(neighbour);
                    }
                }
            }
        }
        result += (area * perimeter);
    }

    return result;
}

pub fn partB(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const a_alloc = arena.allocator();

    var grid = try parseInput(a_alloc, input);

    var plotted = CoordinateSet.init(a_alloc);
    var grid_iter = grid.iterator();

    var result: u64 = 0;
    while (grid_iter.next()) |entry| {
        if (plotted.has(entry.key_ptr.*)) {
            continue;
        }
        const plant = entry.value_ptr.*;
        var corners: u64 = countCorners(entry.key_ptr.*, grid);
        var area: u64 = 1;

        var queue = shared.Queue(Coordinate).init(a_alloc);
        try plotted.add(entry.key_ptr.*);
        try queue.push(entry.key_ptr.*);

        while (queue.remove()) |coord| {
            inline for (directions) |dir| {
                const neighbour = coord.add(dir);
                if (grid.get(neighbour) == plant and !plotted.has(neighbour)) {
                    area += 1;
                    corners += countCorners(neighbour, grid);
                    try plotted.add(neighbour);
                    try queue.push(neighbour);
                }
            }
        }
        result += (area * corners);
    }

    return result;
}

pub fn build() Problem {
    var s = Day12{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}

const directions = [_]Coordinate{ Direction.up.toCoordinate(), Direction.right.toCoordinate(), Direction.down.toCoordinate(), Direction.left.toCoordinate() };
const Grid = std.AutoHashMap(Coordinate, u8);

fn countCorners(coord: Coordinate, grid: Grid) u64 {
    const plant = grid.get(coord);
    var corners: u64 = 0;
    return inline for (directions, 0..) |dir, i| {
        const left = grid.get(coord.add(dir));
        const next_dir = directions[(i + 1) & 3];
        const right = grid.get(coord.add(next_dir));
        const center = grid.get(coord.add(dir.add(next_dir)));
        if ((left != plant and right != plant) or (left == plant and right == plant and center != plant)) {
            corners += 1;
        }
    } else corners;
}

fn parseInput(alloc: std.mem.Allocator, input: []const u8) anyerror!Grid {
    var grid = std.AutoHashMap(Coordinate, u8).init(alloc);
    var line_iter = shared.lineIterator(input);
    var y: i32 = 0;
    while (line_iter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            const coord = Coordinate{ .x = @intCast(x), .y = y };
            try grid.put(coord, char);
        }
    }

    return grid;
}
