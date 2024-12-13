const std = @import("std");
const assert = std.debug.assert;
const Problem = @import("problem.zig");

const Day9 = @This();

pub fn partA(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const a_alloc = arena.allocator();

    const disk = try Disk.init(a_alloc, input);

    var result: u64 = 0;
    var block_pair_node = disk.block_pairs.first;

    var pos: u64 = 0;
    var last_block_pair = disk.block_pairs.last orelse return error.InvalidParameter;

    outer: while (block_pair_node) |block_pair| : (block_pair_node = block_pair.next) {
        while (block_pair.data.file_len > 0) : (block_pair.data.file_len -= 1) {
            result += (pos * block_pair.data.file_id);
            pos += 1;
        }

        while (block_pair.data.free_len > 0) : (block_pair.data.free_len -= 1) {
            if (last_block_pair.data.file_len == 0) {
                last_block_pair = if (last_block_pair.prev) |prev|
                    if (prev.data.file_id > block_pair.data.file_id) prev else break :outer
                else
                    break :outer;
            }
            result += (pos * last_block_pair.data.file_id);
            pos += 1;
            last_block_pair.data.file_len -= 1;
        }
    }

    return result;
}

pub fn partB(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const a_alloc = arena.allocator();

    const disk = try Disk.init(a_alloc, input);

    var result: u64 = 0;
    var block_pair_node = disk.block_pairs.first;

    var pos: u64 = 0;

    while (block_pair_node) |block_pair| : (block_pair_node = block_pair.next) {
        if (block_pair.data.processed) {
            pos += block_pair.data.file_len;
        } else {
            for (0..block_pair.data.file_len) |_| {
                result += (pos * block_pair.data.file_id);
                pos += 1;
            }
            block_pair.data.processed = true;
        }

        var last_block_pair = disk.block_pairs.last;
        while (last_block_pair) |lbp| : (last_block_pair = lbp.prev) {
            if (lbp.data.processed or lbp.data.file_len > block_pair.data.free_len) {
                continue;
            }
            for (0..lbp.data.file_len) |_| {
                result += (pos * lbp.data.file_id);
                pos += 1;
            }
            block_pair.data.free_len -= lbp.data.file_len;
            lbp.data.processed = true;
        }
        pos += block_pair.data.free_len;
    }

    return result;
}

pub fn build() Problem {
    var s = Day9{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}

const Disk = struct {
    const Self = @This();

    const BlockPair = struct {
        file_id: u64,
        file_len: u8,
        free_len: u8,
        processed: bool = false,
    };
    const BlockPairList = std.DoublyLinkedList(BlockPair);

    block_pairs: BlockPairList,

    fn init(alloc: std.mem.Allocator, input: []const u8) anyerror!Self {
        var block_pairs = BlockPairList{};

        var file_id: u64 = 0;
        var it = std.mem.window(u8, input, 2, 2);
        while (it.next()) |chars| : (file_id += 1) {
            var bp_node = try alloc.create(BlockPairList.Node);
            bp_node.data.file_id = file_id;
            bp_node.data.file_len = chars[0] - '0';
            bp_node.data.free_len = if (chars.len == 2) chars[1] - '0' else 0;

            block_pairs.append(bp_node);
        }

        return .{ .block_pairs = block_pairs };
    }
};
