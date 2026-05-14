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

pub const CoordinateSet = struct {
    map: std.AutoHashMap(Coordinate, void),

    pub fn init(allocator: std.mem.Allocator) CoordinateSet {
        return .{ .map = std.AutoHashMap(Coordinate, void).init(allocator) };
    }
    pub fn deinit(self: *CoordinateSet) void {
        self.map.deinit();
    }

    pub fn add(self: *CoordinateSet, value: Coordinate) std.mem.Allocator.Error!void {
        return self.map.put(value, {});
    }

    pub fn has(self: *CoordinateSet, value: Coordinate) bool {
        return self.map.contains(value);
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

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();
        const DLL = std.DoublyLinkedList(T);

        //alloc: std.mem.Allocator,
        arena: std.heap.ArenaAllocator,
        dll: DLL,

        pub fn init(alloc: std.mem.Allocator) Self {
            const arena = std.heap.ArenaAllocator.init(alloc);
            return .{ .arena = arena, .dll = DLL{} };
        }

        pub fn deinit(self: *Self) void {
            self.arena.deinit();
        }

        pub fn push(self: *Self, item: T) std.mem.Allocator.Error!void {
            var node = try self.arena.allocator().create(DLL.Node);
            node.data = item;
            self.dll.append(node);
        }

        pub fn remove(self: *Self) ?T {
            return if (self.dll.popFirst()) |node| node.data else null;
        }
    };
}
