const std = @import("std");

pub const Coordinate = struct {
    x: i32,
    y: i32,

    pub fn add(self: *const Coordinate, other: Coordinate) Coordinate {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn diff(self: *const Coordinate, other: Coordinate) Coordinate {
        return .{ .x = self.x - other.x, .y = self.y - other.y };
    }

    pub fn eq(self: *Coordinate, other: Coordinate) bool {
        return self.x == other.x and self.y == other.y;
    }

    pub fn set(self: *Coordinate, other: Coordinate) void {
        self.x = other.x;
        self.y = other.y;
    }
};

pub const Direction = enum {
    up,
    right,
    down,
    left,

    pub fn toCoordinate(self: Direction) Coordinate {
        return switch (self) {
            Direction.up => .{ .x = 0, .y = -1 },
            Direction.right => .{ .x = 1, .y = 0 },
            Direction.down => .{ .x = 0, .y = 1 },
            Direction.left => .{ .x = -1, .y = 0 },
        };
    }
};

pub fn lineIterator(input: []const u8) std.mem.SplitIterator(u8, .scalar) {
    return std.mem.splitScalar(u8, input, '\n');
}
