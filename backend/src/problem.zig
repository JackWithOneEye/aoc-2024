const std = @import("std");

const Problem = @This();

ptr: *anyopaque,
impl: *const Interface,

pub const Interface = struct {
    partA: *const fn (ctx: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64,
    partB: *const fn (ctx: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64,
};

pub fn partA(self: Problem, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    return self.impl.partA(self.ptr, alloc, input);
}

pub fn partB(self: Problem, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    return self.impl.partB(self.ptr, alloc, input);
}
