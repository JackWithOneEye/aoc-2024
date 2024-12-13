const std = @import("std");
const Problem = @import("problem.zig");

const Day3 = @This();

const Instruction = enum {
    none,
    do,
    dont,
    mul,
};

const Character = enum {
    other,
    d,
    l,
    m,
    n,
    o,
    t,
    u,
    single_quote,
    comma,
    digit,
    open,
    close,
};

pub fn partA(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var result: u64 = 0;
    var prev_token = Character.other;

    var factor_chars = std.ArrayList(u8).init(alloc);
    defer factor_chars.deinit();

    var factor_1: u64 = 0;
    var factor_2: u64 = 0;

    for (input) |ch| {
        const token = switch (ch) {
            'm' => if (prev_token == Character.other or prev_token == Character.close) Character.m else Character.other,
            'u' => if (prev_token == Character.m) Character.u else Character.other,
            'l' => if (prev_token == Character.u) Character.l else Character.other,
            '(' => if (prev_token == Character.l) Character.open else Character.other,
            '0'...'9' => if (prev_token == Character.open or prev_token == Character.comma or prev_token == Character.digit) Character.digit else Character.other,
            ',' => if (prev_token == Character.digit) Character.comma else Character.other,
            ')' => if (prev_token == Character.digit) Character.close else Character.other,
            else => Character.other,
        };
        switch (token) {
            Character.digit => {
                try factor_chars.append(ch);
            },
            Character.comma => {
                factor_1 = try std.fmt.parseInt(u64, factor_chars.items, 10);
                factor_chars.clearRetainingCapacity();
            },
            Character.close => {
                factor_2 = try std.fmt.parseInt(u64, factor_chars.items, 10);
                factor_chars.clearRetainingCapacity();
                result += (factor_1 * factor_2);
            },
            else => {
                if (prev_token == Character.digit) {
                    factor_chars.clearRetainingCapacity();
                }
            },
        }
        prev_token = token;
    }
    return result;
}

pub fn partB(_: *anyopaque, alloc: std.mem.Allocator, input: []const u8) anyerror!u64 {
    var result: u64 = 0;
    var prev_token = Character.other;

    var factor_chars = std.ArrayList(u8).init(alloc);
    defer factor_chars.deinit();

    var factor_1: u64 = 0;
    var factor_2: u64 = 0;

    var do = true;
    var current_instr = Instruction.none;

    for (input) |ch| {
        const token = switch (ch) {
            'd' => if (prev_token == Character.other or prev_token == Character.close) Character.d else Character.other,
            'l' => if (prev_token == Character.u) Character.l else Character.other,
            'm' => if (do and (prev_token == Character.other or prev_token == Character.close)) Character.m else Character.other,
            'n' => if (prev_token == Character.o) Character.n else Character.other,
            'o' => if (prev_token == Character.d) Character.o else Character.other,
            't' => if (prev_token == Character.single_quote) Character.t else Character.other,
            'u' => if (prev_token == Character.m) Character.u else Character.other,
            '\'' => if (prev_token == Character.n) Character.single_quote else Character.other,
            '0'...'9' => if (current_instr == Instruction.mul and (prev_token == Character.open or prev_token == Character.comma or prev_token == Character.digit))
                Character.digit
            else
                Character.other,
            ',' => if (prev_token == Character.digit) Character.comma else Character.other,
            '(' => if (prev_token == Character.l or prev_token == Character.o or prev_token == Character.t) Character.open else Character.other,
            ')' => switch (current_instr) {
                Instruction.do, Instruction.dont => if (prev_token == Character.open) Character.close else Character.other,
                Instruction.mul => if (prev_token == Character.digit) Character.close else Character.other,
                else => unreachable,
            },
            else => Character.other,
        };
        switch (token) {
            Character.d => {
                current_instr = Instruction.do;
            },
            Character.n => {
                current_instr = Instruction.dont;
            },
            Character.m => {
                current_instr = Instruction.mul;
            },
            Character.digit => {
                try factor_chars.append(ch);
            },
            Character.comma => {
                factor_1 = try std.fmt.parseInt(u64, factor_chars.items, 10);
                factor_chars.clearRetainingCapacity();
            },
            Character.close => switch (current_instr) {
                Instruction.do => {
                    do = true;
                },
                Instruction.dont => {
                    do = false;
                },
                Instruction.mul => {
                    factor_2 = try std.fmt.parseInt(u64, factor_chars.items, 10);
                    factor_chars.clearRetainingCapacity();
                    result += (factor_1 * factor_2);
                },
                else => unreachable,
            },
            else => {
                if (prev_token == Character.digit) {
                    factor_chars.clearRetainingCapacity();
                }
            },
        }
        prev_token = token;
    }
    return result;
}

pub fn build() Problem {
    var s = Day3{};
    return Problem{ .ptr = &s, .impl = &.{
        .partA = partA,
        .partB = partB,
    } };
}
