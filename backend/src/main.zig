const std = @import("std");
const zap = @import("zap");

const Problem = @import("problem.zig");
const Day1 = @import("day1.zig");
const Day2 = @import("day2.zig");
const Day3 = @import("day3.zig");
const Day4 = @import("day4.zig");
const Day5 = @import("day5.zig");
const Day6 = @import("day6.zig");
const Day7 = @import("day7.zig");
const Day8 = @import("day8.zig");
const Day9 = @import("day9.zig");
const Day10 = @import("day10.zig");
const Day11 = @import("day11.zig");

var days = [_]Problem{ Day1.build(), Day2.build(), Day3.build(), Day4.build(), Day5.build(), Day6.build(), Day7.build(), Day8.build(), Day9.build(), Day10.build(), Day11.build() };

fn on_request(r: zap.Request) void {
    if (r.path) |the_path| {
        std.debug.print("PATH: {s}\n", .{the_path});
    }

    if (r.query) |the_query| {
        std.debug.print("QUERY: {s}\n", .{the_query});
    }
    r.sendBody("<html><body><h1>Hello from ZAP!!!</h1></body></html>") catch return;
}

const Endpoint = struct {
    alloc: std.mem.Allocator,
    ep: zap.Endpoint,

    const Payload = struct {
        day: u8,
        part: u8,
        input: []const u8,
    };

    pub fn init(alloc: std.mem.Allocator) Endpoint {
        return .{ .alloc = alloc, .ep = zap.Endpoint.init(.{ .path = "/solve", .post = post }) };
    }

    fn post(e: *zap.Endpoint, r: zap.Request) void {
        const self: *Endpoint = @fieldParentPtr("ep", e);
        const body = r.body orelse unreachable;
        const payload: ?std.json.Parsed(Payload) = std.json.parseFromSlice(Payload, self.alloc, body, .{}) catch unreachable;
        if (payload) |p| {
            defer p.deinit();
            var problem = days[p.value.day - 1];

            const result = switch (p.value.part) {
                'a' => problem.partA(self.alloc, p.value.input),
                'b' => problem.partB(self.alloc, p.value.input),
                else => unreachable,
            };
            var buf: [32]u8 = undefined;
            if (result) |success| {
                const str = std.fmt.bufPrint(&buf, "{}", .{success}) catch unreachable;
                r.sendBody(str) catch unreachable;
            } else |err| {
                r.sendError(err, if (@errorReturnTrace()) |t| t.* else null, 500);
            }
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    {
        var listener = zap.Endpoint.Listener.init(allocator, .{
            .port = 3000,
            .on_request = on_request,
            .log = true,
        });
        defer listener.deinit();

        var ep = Endpoint.init(allocator);

        try listener.register(&ep.ep);

        try listener.listen();
        std.debug.print("Listening on 0.0.0.0:3000\n", .{});

        zap.start(.{
            .threads = 1,
            .workers = 1,
        });
    }

    const has_leaked = gpa.detectLeaks();
    std.log.debug("Has leaked: {}\n", .{has_leaked});
}
