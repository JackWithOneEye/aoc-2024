const std = @import("std");
const math = std.math;
const Problem = @import("problem.zig");

const Day4 = @This();

const Coordinate = struct {
    x: usize,
    y: usize,
};

const Direction = enum { top, top_right, right, bottom_right, bottom, bottom_left, left, top_left };
const directions = [_]Direction{ Direction.top, Direction.top_right, Direction.right, Direction.bottom_right, Direction.bottom, Direction.bottom_left, Direction.left, Direction.top_left };
const Letter = enum { X, M, A, S };

pub fn partA(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var result: u64 = 0;

    var grid = std.ArrayList([]const u8).init(alloc);
    defer grid.deinit();

    var start_coordinates = std.ArrayList(Coordinate).init(alloc);
    defer start_coordinates.deinit();

    var lines_iter = std.mem.splitScalar(u8, input, '\n');

    var y: usize = 0;
    while (lines_iter.next()) |line| : (y += 1) {
        try grid.append(line);

        for (line, 0..) |char, x| {
            if (char == 'X') {
                try start_coordinates.append(.{ .x = x, .y = y });
            }
        }
    }

    const row_len = grid.items[0].len;
    const max_coord = Coordinate{ .x = row_len - 1, .y = y - 1 };

    for (start_coordinates.items) |start| {
        inline for (directions) |dir| {
            if (xmasWalk(grid, start, dir, Letter.X, max_coord)) {
                result += 1;
            }
        }
    }

    return result;
}

pub fn partB(_: *anyopaque, _: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var result: u64 = 0;

    var lines_iter = std.mem.splitScalar(u8, input, '\n');

    var prev_line = lines_iter.first();
    while (lines_iter.next()) |line| : (prev_line = line) {
        if (lines_iter.peek()) |next_line| {
            for (1..line.len - 1) |x| {
                const char = line[x];
                if (char != 'A') {
                    continue;
                }
                const x_l = x - 1;
                const x_r = x + 1;
                const x_mas = switch (prev_line[x_l]) {
                    'M' => next_line[x_r] == 'S',
                    'S' => next_line[x_r] == 'M',
                    else => false,
                } and switch (prev_line[x_r]) {
                    'M' => next_line[x_l] == 'S',
                    'S' => next_line[x_l] == 'M',
                    else => false,
                };

                if (x_mas) {
                    result += 1;
                }
            }
        } else break;
    }

    return result;
}

pub fn build() Problem {
    var s = Day4{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}

fn xmasWalk(grid: std.ArrayList([]const u8), coord: Coordinate, dir: Direction, current_letter: Letter, max_coord: Coordinate) bool {
    const next_coord: Coordinate = switch (dir) {
        Direction.top => .{
            .x = coord.x,
            .y = math.sub(usize, coord.y, 1) catch return false,
        },

        Direction.top_right => .{
            .x = coord.x + 1,
            .y = math.sub(usize, coord.y, 1) catch return false,
        },
        Direction.right => .{
            .x = coord.x + 1,
            .y = coord.y,
        },
        Direction.bottom_right => .{
            .x = coord.x + 1,
            .y = coord.y + 1,
        },
        Direction.bottom => .{
            .x = coord.x,
            .y = coord.y + 1,
        },
        Direction.bottom_left => .{
            .x = math.sub(usize, coord.x, 1) catch return false,
            .y = coord.y + 1,
        },
        Direction.left => .{
            .x = math.sub(usize, coord.x, 1) catch return false,
            .y = coord.y,
        },
        Direction.top_left => .{
            .x = math.sub(usize, coord.x, 1) catch return false,
            .y = math.sub(usize, coord.y, 1) catch return false,
        },
    };

    if (next_coord.x > max_coord.x or next_coord.y > max_coord.y) {
        return false;
    }

    const char = grid.items[next_coord.y][next_coord.x];
    return switch (char) {
        'M' => if (current_letter == Letter.X)
            xmasWalk(grid, next_coord, dir, Letter.M, max_coord)
        else
            false,
        'A' => if (current_letter == Letter.M)
            xmasWalk(grid, next_coord, dir, Letter.A, max_coord)
        else
            false,
        'S' => current_letter == Letter.A,
        else => false,
    };
}
