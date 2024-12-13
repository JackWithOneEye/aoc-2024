const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");

const shared = @import("shared.zig");
const Coordinate = shared.Coordinate;
const Direction = shared.Direction;

const Day6 = @This();

const directions = [_]Coordinate{ Direction.up.toCoordinate(), Direction.right.toCoordinate(), Direction.down.toCoordinate(), Direction.left.toCoordinate() };
const directions_wrap_mask: usize = 3;

pub fn partA(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var positions = try Positions.init(alloc, input);
    defer positions.deinit();

    return positions.visited.count();
}

pub fn partB(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var positions = try Positions.init(alloc, input);
    defer positions.deinit();

    var visited_iter = positions.visited.keyIterator();

    var track = std.AutoHashMap(Coordinate, void).init(alloc);
    defer track.deinit();
    var loop_track = std.AutoHashMap(Coordinate, void).init(alloc);
    defer loop_track.deinit();

    var loop_obstacles_cnt: u64 = 0;
    while (visited_iter.next()) |visited| {
        if (visited.eq(positions.start_guard_pos)) {
            continue;
        }
        defer track.clearRetainingCapacity();
        defer loop_track.clearRetainingCapacity();

        try positions.obstacles.put(visited.*, {});
        defer _ = positions.obstacles.remove(visited.*);

        var guard_pos: Coordinate = undefined;
        guard_pos.set(positions.start_guard_pos);
        var guard_dir_idx = positions.start_guard_dir_idx;
        try track.put(guard_pos, {});

        while (guard_pos.x >= 0 and guard_pos.x <= positions.max_x and guard_pos.y >= 0 and guard_pos.y <= positions.max_y) {
            const moved_to = guard_pos.add(directions[guard_dir_idx]);
            if (!positions.obstacles.contains(moved_to)) {
                guard_pos.set(moved_to);
                continue;
            }
            if (track.contains(moved_to)) {
                if (loop_track.contains(moved_to)) {
                    loop_obstacles_cnt += 1;
                    break;
                }
                try loop_track.put(moved_to, {});
            } else {
                loop_track.clearRetainingCapacity();
            }
            try track.put(moved_to, {});
            guard_dir_idx = (guard_dir_idx + 1) & directions_wrap_mask;
        }
    }

    return loop_obstacles_cnt;
}

pub fn build() Problem {
    var s = Day6{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}

const Positions = struct {
    obstacles: std.AutoHashMap(Coordinate, void),
    visited: std.AutoHashMap(Coordinate, void),
    max_x: i32,
    max_y: i32,
    start_guard_pos: Coordinate,
    start_guard_dir_idx: usize,

    fn init(alloc: std.mem.Allocator, input: []const u8) anyerror!Positions {
        var start_guard_pos: Coordinate = undefined;
        var start_guard_dir_idx: usize = undefined;
        var obstacles = std.AutoHashMap(Coordinate, void).init(alloc);

        var lines_iter = std.mem.splitScalar(u8, input, '\n');

        const max_x: i32 = @intCast(lines_iter.peek().?.len - 1);
        var y: i32 = 0;
        while (lines_iter.next()) |line| : (y += 1) {
            for (line, 0..) |char, x| {
                const coord = Coordinate{ .x = @intCast(x), .y = y };
                switch (char) {
                    '^' => {
                        start_guard_pos.set(coord);
                        start_guard_dir_idx = 0;
                    },
                    '>' => {
                        start_guard_pos.set(coord);
                        start_guard_dir_idx = 1;
                    },
                    'v' => {
                        start_guard_pos.set(coord);
                        start_guard_dir_idx = 2;
                    },
                    '<' => {
                        start_guard_pos.set(coord);
                        start_guard_dir_idx = 3;
                    },
                    '#' => {
                        try obstacles.put(coord, {});
                    },
                    else => {},
                }
            }
        }
        const max_y: i32 = y - 1;

        var visited = std.AutoHashMap(Coordinate, void).init(alloc);

        var guard_pos: Coordinate = undefined;
        guard_pos.set(start_guard_pos);
        var guard_dir_idx = start_guard_dir_idx;
        while (guard_pos.x >= 0 and guard_pos.x <= max_x and guard_pos.y >= 0 and guard_pos.y <= max_y) {
            try visited.put(guard_pos, {});
            const moved_to = guard_pos.add(directions[guard_dir_idx]);
            if (obstacles.contains(moved_to)) {
                guard_dir_idx = (guard_dir_idx + 1) & directions_wrap_mask;
                continue;
            }
            guard_pos.set(moved_to);
        }

        return .{ .obstacles = obstacles, .visited = visited, .max_x = max_x, .max_y = max_y, .start_guard_dir_idx = start_guard_dir_idx, .start_guard_pos = start_guard_pos };
    }

    fn deinit(self: *Positions) void {
        self.obstacles.deinit();
        self.visited.deinit();
    }
};
