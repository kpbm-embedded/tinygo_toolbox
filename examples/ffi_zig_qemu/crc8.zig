//! CRC-8 (poly 0x07, init 0) exported with the C ABI, linked into TinyGo firmware via cgo.
export fn zig_crc8(p: [*]const u8, n: usize) u8 {
    var c: u8 = 0;
    for (p[0..n]) |b| {
        c ^= b;
        for (0..8) |_| {
            c = if (c & 0x80 != 0) (c << 1) ^ 0x07 else c << 1;
        }
    }
    return c;
}
