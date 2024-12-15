const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");

const shared = @import("shared.zig");
const Coordinate = shared.Coordinate;
const Direction = shared.Direction;

const Day10 = @This();

pub fn partA(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var topo = try TopoMap.init(alloc, input);
    defer topo.deinit();

    var result: u64 = 0;

    var visited = std.AutoHashMap(Coordinate, void).init(alloc);
    defer visited.deinit();
    for (topo.zeros.items) |coord| {
        defer visited.clearRetainingCapacity();
        try accTrailheads(topo.grid, coord, '0', &visited, &result);
    }

    return result;
}

pub fn partB(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var topo = try TopoMap.init(alloc, input);
    defer topo.deinit();

    var result: u64 = 0;
    for (topo.zeros.items) |coord| {
        try accTrailheads(topo.grid, coord, '0', null, &result);
    }

    return result;
}

pub fn build() Problem {
    var s = Day10{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}

const Grid = std.AutoHashMap(Coordinate, u8);

const TopoMap = struct {
    grid: Grid,
    zeros: std.ArrayList(Coordinate),

    fn init(alloc: std.mem.Allocator, input: []const u8) anyerror!TopoMap {
        var grid = Grid.init(alloc);
        var zeros = std.ArrayList(Coordinate).init(alloc);

        var lines_iter = std.mem.splitScalar(u8, input, '\n');
        var y: i32 = 0;
        while (lines_iter.next()) |line| : (y += 1) {
            for (line, 0..) |char, x| {
                const coord = Coordinate{ .x = @intCast(x), .y = y };
                if (char == '0') {
                    try zeros.append(coord);
                }
                try grid.put(coord, char);
            }
        }

        return .{ .grid = grid, .zeros = zeros };
    }

    fn deinit(self: *TopoMap) void {
        self.grid.deinit();
        self.zeros.deinit();
    }
};

const directions = [_]Coordinate{ Direction.up.toCoordinate(), Direction.right.toCoordinate(), Direction.down.toCoordinate(), Direction.left.toCoordinate() };

fn accTrailheads(grid: Grid, position: Coordinate, height: u8, visited: ?*std.AutoHashMap(Coordinate, void), acc: *u64) anyerror!void {
    if (visited) |v| {
        if (v.contains(position)) {
            return;
        }
        try v.put(position, {});
    }

    if (height == '9') {
        acc.* += 1;
        return;
    }

    const next_height = height + 1;

    inline for (directions) |coord| {
        const next = position.add(coord);
        if (grid.get(next) == next_height) {
            try accTrailheads(grid, next, next_height, visited, acc);
        }
    }
}
