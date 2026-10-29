//! Fixed-point exponential moving average in Zig, exported with the C ABI for TinyGo (cgo).
const Ema = extern struct { acc: i32, shift: u8 };

export fn ema_init(e: *Ema, shift: u8, first: i32) void {
    e.* = .{ .acc = first << @intCast(shift), .shift = shift };
}

export fn ema_step(e: *Ema, x: i32) i32 {
    const s: u5 = @intCast(e.shift);
    e.acc += x - (e.acc >> s);
    return e.acc >> s;
}
